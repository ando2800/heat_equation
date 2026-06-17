program main_2d
   use heat_parameters, only: wp
   use solver_2d, only: solve_heat_2d
   implicit none

   integer, parameter :: nx = 50
   integer, parameter :: ny = 50
   integer, parameter :: nt = 500
   integer, parameter :: output_every = 10
   real(wp), parameter :: dt = -1.0_wp
   real(wp), parameter :: alpha = 0.01_wp
   real(wp), parameter :: lx = 1.0_wp
   real(wp), parameter :: ly = 1.0_wp

   character(len=256) :: output_dir, initial, boundary, vtk_arg
   logical :: vtk

   output_dir = 'output/fortran/2d'
   initial = 'square'
   boundary = 'dirichlet'
   vtk_arg = ''
   vtk = .true.

   call read_arg(1, output_dir)
   call read_arg(2, initial)
   call read_arg(3, boundary)
   call read_arg(4, vtk_arg)
   if (len_trim(vtk_arg) > 0) vtk = trim(vtk_arg) /= 'no-vtk'

   call solve_heat_2d(nx, ny, nt, output_every, dt, alpha, lx, ly, output_dir, initial, boundary, vtk)
   write(*,*) 'Calculation finished. Output directory:', trim(output_dir)

contains

   subroutine read_arg(index, value)
      integer, intent(in) :: index
      character(len=*), intent(inout) :: value

      if (command_argument_count() >= index) call get_command_argument(index, value)
   end subroutine read_arg

end program main_2d
