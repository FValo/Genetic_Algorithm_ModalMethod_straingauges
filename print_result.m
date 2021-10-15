close all
clc

x1=gen.displ_value(1:3:end);
y1=gen.displ_value(2:3:end);
z1=gen.displ_value(3:3:end);

x2=gen.displ_calculated(1:3:end);
y2=gen.displ_calculated(2:3:end);
z2=gen.displ_calculated(3:3:end);
err=100*sqrt( 1/length(z1) * sum( ( (z1-z2)/max(abs(z1)) ).^2 ) );

load report/semiala_beam/display_semialabeam;
% load report/clumped_plate_randomloads/display_clumpedplate_randomloads;

figure(2)
% quadmesh(conn_plate_rand,x_plate_rand,y_plate_rand,z_plate_rand);
quadmesh(conn,x+x1,y+y1,z+z1,0.8*ones(length(x),1));
hold on
quadmesh(conn,x+x2,y+y2,z+z2,0.2*ones(length(x),1));
% axis equal
legend('FEM displ','Modal Method displ');
xlabel('x')
ylabel('y')
zlabel('z')