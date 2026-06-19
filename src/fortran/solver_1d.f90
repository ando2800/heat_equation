module solver_1d
   use heat_parameters, only: wp
   use boundary_condition, only: apply_boundary_1d
   use initial_condition, only: set_initial_1d
   use io_field, only: write_profile, write_vtk_1d
   implicit none

contains

   subroutine solve_heat_1d(nx, nt, output_every, dt, alpha, lx, output_dir, initial, boundary, vtk, method)
      integer, intent(in) :: nx, nt, output_every
      real(wp), intent(in) :: dt, alpha, lx
      character(len=*), intent(in) :: output_dir, initial, boundary, method
      logical, intent(in) :: vtk

      real(wp), allocatable :: temp(:), next_temp(:), work_temp(:)
      real(wp), allocatable :: k1(:), k2(:), k3(:), k4(:)
      real(wp) :: dx, r, dtmax, laplacian
      integer :: i, step, frame

      dx = lx / real(nx, wp)
      r = alpha * dt / (dx * dx)
      if (trim(method) == 'euler' .and. r > 0.5_wp) then
         dtmax = 0.5_wp * dx * dx / alpha
         write(*,*) 'Error: unstable time step. r=', r, ' dtmax=', dtmax
         error stop
      end if

      allocate(temp(0:nx), next_temp(0:nx), work_temp(0:nx))
      allocate(k1(0:nx), k2(0:nx), k3(0:nx), k4(0:nx))
      call set_initial_1d(initial, temp, nx, lx)
      call apply_boundary_1d(temp, nx, boundary)

      frame = 0
      call write_profile(output_dir, frame, temp, nx, dx, lx)
      if (vtk) call write_vtk_1d(output_dir, frame, temp, nx, dx, lx)

      do step = 1, nt

         select case (trim(method))

            ! --- Euler ---
          case ('euler')
            do i = 1, nx - 1
               laplacian = (temp(i+1) - 2.0_wp*temp(i) + temp(i-1)) / (dx*dx)
               next_temp(i) = temp(i) + alpha * dt * laplacian
            end do

            ! --- RK4 ---
          case ('rk4')
            ! k1
            do i = 1, nx - 1
               k1(i) = alpha * dt * (temp(i+1) - 2.0_wp*temp(i) + temp(i-1)) / (dx*dx)
            end do
            ! k2
            work_temp = temp
            do i = 1, nx - 1
               work_temp(i) = temp(i) + 0.5_wp * k1(i)
            end do
            call apply_boundary_1d(work_temp, nx, boundary)
            do i = 1, nx - 1
               k2(i) = alpha * dt * (work_temp(i+1) - 2.0_wp*work_temp(i) + work_temp(i-1)) / (dx*dx)
            end do
            ! k3
            work_temp = temp
            do i = 1, nx - 1
               work_temp(i) = temp(i) + 0.5_wp * k2(i)
            end do
            call apply_boundary_1d(work_temp, nx, boundary)
            do i = 1, nx - 1
               k3(i) = alpha * dt * (work_temp(i+1) - 2.0_wp*work_temp(i) + work_temp(i-1)) / (dx*dx)
            end do
            ! k4
            work_temp = temp
            do i = 1, nx - 1
               work_temp(i) = temp(i) + k3(i)
            end do
            call apply_boundary_1d(work_temp, nx, boundary)
            do i = 1, nx - 1
               k4(i) = alpha * dt * (work_temp(i+1) - 2.0_wp*work_temp(i) + work_temp(i-1)) / (dx*dx)
            end do
            ! 加重平均で更新
            do i = 1, nx - 1
               next_temp(i) = temp(i) + (k1(i) + 2.0_wp*k2(i) + 2.0_wp*k3(i) + k4(i)) / 6.0_wp
            end do
         end select

         ! --- 境界条件・更新・出力 ---
         call apply_boundary_1d(next_temp, nx, boundary)
         temp = next_temp

         if (mod(step, output_every) == 0) then
            frame = frame + 1
            call write_profile(output_dir, frame, temp, nx, dx, lx)
            if (vtk) call write_vtk_1d(output_dir, frame, temp, nx, dx, lx)
         end if

      end do

   end subroutine solve_heat_1d

end module solver_1d
