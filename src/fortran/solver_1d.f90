module solver_1d
   use heat_parameters, only: wp
   use boundary_condition, only: apply_boundary_1d
   use initial_condition, only: set_initial_1d
   use io_field, only: write_profile, write_vtk_1d
   implicit none

contains

   subroutine solve_heat_1d(nx, nt, output_every, dt, alpha, lx, output_dir, initial, boundary, vtk)
      integer, intent(in) :: nx, nt, output_every
      real(wp), intent(in) :: dt, alpha, lx
      character(len=*), intent(in) :: output_dir, initial, boundary
      logical, intent(in) :: vtk

      real(wp), allocatable :: temp(:), next_temp(:)
      real(wp) :: dx, r, dtmax, laplacian
      integer :: i, step, frame

      dx = lx / real(nx, wp)
      r = alpha * dt / (dx * dx)
      if (r > 0.5_wp) then
         dtmax = 0.5_wp * dx * dx / alpha
         write(*,*) 'Error: unstable time step. r=', r, ' dtmax=', dtmax
         error stop
      end if

      allocate(temp(0:nx), next_temp(0:nx))
      call set_initial_1d(initial, temp, nx, lx)
      call apply_boundary_1d(temp, nx, boundary)

      frame = 0
      call write_profile(output_dir, frame, temp, nx, dx, lx)
      if (vtk) call write_vtk_1d(output_dir, frame, temp, nx, dx, lx)

      do step = 1, nt
         next_temp = temp
         do i = 1, nx - 1
            laplacian = (temp(i + 1) - 2.0_wp * temp(i) + temp(i - 1)) / (dx * dx)
            next_temp(i) = temp(i) + alpha * dt * laplacian
         end do
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
