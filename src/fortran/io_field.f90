module io_field
   use heat_parameters, only: wp
   implicit none

contains

   subroutine ensure_directory(output_dir)
      character(len=*), intent(in) :: output_dir
      call execute_command_line('mkdir -p ' // trim(output_dir))
   end subroutine ensure_directory

   subroutine write_profile(output_dir, frame, values, nx, dx, lx)
      character(len=*), intent(in) :: output_dir
      integer, intent(in) :: frame, nx
      real(wp), intent(in) :: values(0:nx), dx, lx

      character(len=4) :: serial
      character(len=512) :: filename
      integer :: i

      call ensure_directory(output_dir)
      write(serial, '(i4.4)') frame
      filename = trim(output_dir) // '/temp.' // serial

      open(10, file=trim(filename), status='replace')
      do i = 0, nx
         write(10, '(2ES20.12)') real(i, wp) * dx - lx / 2.0_wp, values(i)
      end do
      close(10)
   end subroutine write_profile

   subroutine write_field(output_dir, frame, field, nx, ny, dx, dy)
      character(len=*), intent(in) :: output_dir
      integer, intent(in) :: frame, nx, ny
      real(wp), intent(in) :: field(0:nx, 0:ny), dx, dy

      character(len=4) :: serial
      character(len=512) :: filename
      integer :: i, j

      call ensure_directory(output_dir)
      write(serial, '(i4.4)') frame
      filename = trim(output_dir) // '/field.' // serial

      open(10, file=trim(filename), status='replace')
      do j = 0, ny
         do i = 0, nx
            write(10, '(3ES20.12)') real(i, wp) * dx, real(j, wp) * dy, field(i, j)
         end do
         write(10, *)
      end do
      close(10)
   end subroutine write_field

   subroutine write_vtk_1d(output_dir, frame, values, nx, dx, lx)
      character(len=*), intent(in) :: output_dir
      integer, intent(in) :: frame, nx
      real(wp), intent(in) :: values(0:nx), dx, lx

      character(len=4) :: serial
      character(len=512) :: filename
      integer :: i

      call ensure_directory(output_dir)
      write(serial, '(i4.4)') frame
      filename = trim(output_dir) // '/temp.' // serial // '.vtk'

      open(10, file=trim(filename), status='replace')
      write(10, '(A)') '# vtk DataFile Version 3.0'
      write(10, '(A)') '1-D heat equation'
      write(10, '(A)') 'ASCII'
      write(10, '(A)') 'DATASET STRUCTURED_GRID'
      write(10, '(A,I0,A)') 'DIMENSIONS ', nx + 1, ' 1 1'
      write(10, '(A,I0,A)') 'POINTS ', nx + 1, ' float'
      do i = 0, nx
         write(10, '(3ES20.12)') real(i, wp) * dx - lx / 2.0_wp, 0.0_wp, 0.0_wp
      end do
      write(10, '(A,I0)') 'POINT_DATA ', nx + 1
      write(10, '(A)') 'SCALARS temperature float 1'
      write(10, '(A)') 'LOOKUP_TABLE default'
      do i = 0, nx
         write(10, '(ES20.12)') values(i)
      end do
      close(10)
   end subroutine write_vtk_1d

   subroutine write_vtk_2d(output_dir, frame, field, nx, ny, dx, dy)
      character(len=*), intent(in) :: output_dir
      integer, intent(in) :: frame, nx, ny
      real(wp), intent(in) :: field(0:nx, 0:ny), dx, dy

      character(len=4) :: serial
      character(len=512) :: filename
      integer :: i, j

      call ensure_directory(output_dir)
      write(serial, '(i4.4)') frame
      filename = trim(output_dir) // '/field.' // serial // '.vtk'

      open(10, file=trim(filename), status='replace')
      write(10, '(A)') '# vtk DataFile Version 3.0'
      write(10, '(A)') '2-D heat equation'
      write(10, '(A)') 'ASCII'
      write(10, '(A)') 'DATASET STRUCTURED_POINTS'
      write(10, '(A,3I8)') 'DIMENSIONS', nx + 1, ny + 1, 1
      write(10, '(A)') 'ORIGIN 0.0 0.0 0.0'
      write(10, '(A,3ES20.12)') 'SPACING', dx, dy, 1.0_wp
      write(10, '(A,I0)') 'POINT_DATA ', (nx + 1) * (ny + 1)
      write(10, '(A)') 'SCALARS temperature float 1'
      write(10, '(A)') 'LOOKUP_TABLE default'
      do j = 0, ny
         do i = 0, nx
            write(10, '(ES20.12)') field(i, j)
         end do
      end do
      close(10)
   end subroutine write_vtk_2d

end module io_field
