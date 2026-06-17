module solver_2d
   use heat_parameters, only: wp
   use boundary_condition, only: apply_boundary_2d
   use initial_condition, only: set_initial_2d
   use io_field, only: write_field, write_vtk_2d
   implicit none

contains

   subroutine solve_heat_2d(nx, ny, nt, output_every, dt_arg, alpha, lx, ly, output_dir, initial, boundary, vtk)
      integer, intent(in) :: nx, ny, nt, output_every
      real(wp), intent(in) :: dt_arg, alpha, lx, ly
      character(len=*), intent(in) :: output_dir, initial, boundary
      logical, intent(in) :: vtk

      real(wp), allocatable :: field(:,:), next_field(:,:)
      real(wp) :: dx, dy, dt, stability_limit, d2x, d2y
      integer :: i, j, step, frame

      dx = lx / real(nx, wp)
      dy = ly / real(ny, wp)
      if (dt_arg > 0.0_wp) then
         dt = dt_arg
      else
         dt = 0.25_wp * min(dx, dy)**2 / alpha
      end if

      stability_limit = 1.0_wp / (2.0_wp * alpha * (1.0_wp / dx**2 + 1.0_wp / dy**2))
      if (dt > stability_limit) then
         write(*,*) 'Error: unstable time step. dt=', dt, ' dtmax=', stability_limit
         error stop
      end if

      allocate(field(0:nx, 0:ny), next_field(0:nx, 0:ny))
      call set_initial_2d(initial, field, nx, ny, lx, ly)
      next_field = 0.0_wp
      call apply_boundary_2d(field, nx, ny, boundary)

      frame = 0
      call write_field(output_dir, frame, field, nx, ny, dx, dy)
      if (vtk) call write_vtk_2d(output_dir, frame, field, nx, ny, dx, dy)

      do step = 1, nt
         call apply_boundary_2d(field, nx, ny, boundary)

         do j = 1, ny - 1
            do i = 1, nx - 1
               d2x = (field(i + 1, j) - 2.0_wp * field(i, j) + field(i - 1, j)) / dx**2
               d2y = (field(i, j + 1) - 2.0_wp * field(i, j) + field(i, j - 1)) / dy**2
               next_field(i, j) = field(i, j) + alpha * dt * (d2x + d2y)
            end do
         end do

         call apply_boundary_2d(next_field, nx, ny, boundary)
         field = next_field

         if (mod(step, output_every) == 0) then
            frame = frame + 1
            call write_field(output_dir, frame, field, nx, ny, dx, dy)
            if (vtk) call write_vtk_2d(output_dir, frame, field, nx, ny, dx, dy)
         end if

         if (mod(step, 100) == 0) write(*,*) 'Step:', step
      end do
   end subroutine solve_heat_2d

end module solver_2d
