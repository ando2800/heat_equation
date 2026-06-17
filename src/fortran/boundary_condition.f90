module boundary_condition
   use heat_parameters, only: wp
   implicit none

contains

   subroutine apply_boundary_1d(values, nx, boundary)
      integer, intent(in) :: nx
      real(wp), intent(inout) :: values(0:nx)
      character(len=*), intent(in) :: boundary

      select case (trim(boundary))
      case ('dirichlet')
         values(0) = 0.0_wp
         values(nx) = 0.0_wp
      case ('neumann')
         values(0) = values(1)
         values(nx) = values(nx - 1)
      case ('periodic')
         values(0) = values(nx - 1)
         values(nx) = values(1)
      case default
         error stop 'unknown 1-D boundary condition'
      end select
   end subroutine apply_boundary_1d

   subroutine apply_boundary_2d(field, nx, ny, boundary)
      integer, intent(in) :: nx, ny
      real(wp), intent(inout) :: field(0:nx, 0:ny)
      character(len=*), intent(in) :: boundary

      integer :: i, j

      select case (trim(boundary))
      case ('dirichlet')
         field(0, :) = 0.0_wp
         field(nx, :) = 0.0_wp
         field(:, 0) = 0.0_wp
         field(:, ny) = 0.0_wp
      case ('neumann')
         do i = 1, nx - 1
            field(i, 0) = field(i, 1)
            field(i, ny) = field(i, ny - 1)
         end do
         do j = 1, ny - 1
            field(0, j) = field(1, j)
            field(nx, j) = field(nx - 1, j)
         end do
         field(0, 0) = field(1, 1)
         field(0, ny) = field(1, ny - 1)
         field(nx, 0) = field(nx - 1, 1)
         field(nx, ny) = field(nx - 1, ny - 1)
      case ('periodic')
         do i = 1, nx - 1
            field(i, 0) = field(i, ny - 1)
            field(i, ny) = field(i, 1)
         end do
         do j = 1, ny - 1
            field(0, j) = field(nx - 1, j)
            field(nx, j) = field(1, j)
         end do
         field(0, 0) = field(nx - 1, ny - 1)
         field(0, ny) = field(nx - 1, 1)
         field(nx, 0) = field(1, ny - 1)
         field(nx, ny) = field(1, 1)
      case default
         error stop 'unknown 2-D boundary condition'
      end select
   end subroutine apply_boundary_2d

end module boundary_condition
