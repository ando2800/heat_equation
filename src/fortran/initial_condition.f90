module initial_condition
   use heat_parameters, only: wp
   implicit none

contains

   subroutine set_initial_1d(name, values, nx, lx)
      character(len=*), intent(in) :: name
      integer, intent(in) :: nx
      real(wp), intent(in) :: lx
      real(wp), intent(out) :: values(0:nx)

      real(wp) :: dx, x
      integer :: i

      dx = lx / real(nx, wp)

      do i = 0, nx
         x = real(i, wp) * dx - lx / 2.0_wp
         select case (trim(name))
         case ('semicircle')
            values(i) = sqrt(max(0.0_wp, 1.0_wp - x*x))
         case ('gaussian')
            values(i) = exp(-40.0_wp * x*x)
         case ('sine')
            values(i) = sin(acos(-1.0_wp) * (x + lx / 2.0_wp) / lx)
         case default
            error stop 'unknown 1-D initial condition'
         end select
      end do
   end subroutine set_initial_1d

   subroutine set_initial_2d(name, field, nx, ny, lx, ly)
      character(len=*), intent(in) :: name
      integer, intent(in) :: nx, ny
      real(wp), intent(in) :: lx, ly
      real(wp), intent(out) :: field(0:nx, 0:ny)

      real(wp) :: dx, dy, x, y
      integer :: i, j

      dx = lx / real(nx, wp)
      dy = ly / real(ny, wp)
      field = 0.0_wp

      select case (trim(name))
      case ('square')
         field(nx/4:3*nx/4, ny/4:3*ny/4) = 1.0_wp
      case ('gaussian')
         do j = 0, ny
            y = real(j, wp) * dy - ly / 2.0_wp
            do i = 0, nx
               x = real(i, wp) * dx - lx / 2.0_wp
               field(i, j) = exp(-50.0_wp * (x*x + y*y))
            end do
         end do
      case ('sine')
         do j = 0, ny
            y = real(j, wp) * dy
            do i = 0, nx
               x = real(i, wp) * dx
               field(i, j) = sin(acos(-1.0_wp) * x / lx) * sin(acos(-1.0_wp) * y / ly)
            end do
         end do
      case default
         error stop 'unknown 2-D initial condition'
      end select
   end subroutine set_initial_2d

end module initial_condition
