program main_1d
   use heat_parameters, only: wp
   use solver_1d, only: solve_heat_1d
   implicit none

   integer, parameter :: nx = 32
   integer, parameter :: nt = 2500
   integer, parameter :: output_every = 50
   real(wp), parameter :: dt = 1.0e-3_wp
   real(wp), parameter :: alpha = 1.0_wp
   real(wp), parameter :: lx = 2.0_wp

   character(len=256) :: output_dir, initial, boundary, vtk_arg
   logical :: vtk

   output_dir = 'output/fortran/1d'
   initial = 'semicircle'
   boundary = 'dirichlet'
   vtk_arg = ''
   vtk = .true.

   call read_arg(1, output_dir)
   call read_arg(2, initial)
   call read_arg(3, boundary)
   call read_arg(4, vtk_arg)
   if (len_trim(vtk_arg) > 0) vtk = trim(vtk_arg) /= 'no-vtk'

   call solve_heat_1d(nx, nt, output_every, dt, alpha, lx, output_dir, initial, boundary, vtk, 'euler')
   write(*,*) 'Calculation finished. Output directory:', trim(output_dir)

contains

   subroutine read_arg(index, value)
      integer, intent(in) :: index
      character(len=*), intent(inout) :: value

      if (command_argument_count() >= index) call get_command_argument(index, value)
   end subroutine read_arg

end program main_1d
