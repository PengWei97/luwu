%1、生成voronoi图
clear;clc;
%Outer boundary
%Draw the cube
L = input('模型长度L：');
W = input('模型宽度W：');
cb = zeros(5,2);
cb(2,1) = L; cb(3,1) = L;
cb(3,2) = W; cb(4,2) = W;
cb(5,1) = L/2.0;
cb(5,2) = W/2.0;
cb(:,1) = cb(:,1)-L/2.;
cb(:,2) = cb(:,2)-W/2.;
d = [1 2 3 4 1];
plot(cb(d,1),cb(d,2),'k-'); axis equal

%Seeding
s1 = input('第1层晶粒数量：');
x1 = L*rand(s1,1)-L/2.;
y1 = W*(0.3*rand(s1,1)+0.7)-W/2.;

s2 = input('第2层晶粒数量：');
x2 = L*rand(s2,1)-L/2.;
y2 = W*(0.3*rand(s2,1)+0.4)-W/2.;

s3 = input('第3层晶粒数量：');
x3 = L*rand(s3,1)-L/2.;
y3 = W*(0.1*rand(s3,1)+0.3)-W/2.;

s4 = input('第4层晶粒数量：');
x4 = L*rand(s4,1)-L/2.;
y4 = W*(0.1*rand(s4,1)+0.2)-W/2.;

s5 = input('第5层晶粒数量：');
x5 = L*rand(s5,1)-L/2.;
y5 = W*(0.2*rand(s5,1))-W/2.;
s=s1+s2+s3+s4+s5;
%%%%%
x = [x1' x2' x3' x4' x5']';
y = [y1' y2' y3' y4' y5']';
%Add mirror pts
xx = [x;-L-x;L-x;   x;  x;];
yy = [y;   y;  y;-W-y;W-y;];
%Voronoi
[V,C] = voronoin([xx,yy]);
%可视化
for i = 1:length(C)
	if all(C{i}~=1)   % If at least one of the indices is 1,
                  % then it is an open region and we can't
                  % patch that.
		Verts = V(C{i},:);
		CoordAbsx = abs(Verts(:,1));
		CoordAbsy = abs(Verts(:,2));
		if all(CoordAbsx <= L/2.+eps(single(L/2.))) && all(CoordAbsy <= W/2.+eps(single(W/2.))) %within boundary
			patch(V(C{i},1),V(C{i},2),i); % use color i.
		end
	end
end
view(2)

%2、生成各点坐标
f=fullfile('E:','Matlab\GrainGrowth','grain_topology_coords.txt');
fileID = fopen(f,'w');
[mmm,nnn]=size(V);
fprintf(fileID,'%f,%f\n',10000,10000);
for i=2:mmm
	fprintf(fileID,'%f,%f\n',V(i,1), V(i,2));
end
fclose(fileID);

%3、生成各晶粒顶点连接顺序
f=fullfile('E:','Matlab\GrainGrowth','grain_topology_connection.txt');
fileID = fopen(f,'w');
for i=1:s
	for j=1:size(C{i,:})
		fprintf(fileID,'%d,',C{i,j});
	end
	fprintf(fileID,'\n');
end
fclose(fileID);

%4、输出voronoi核心
f=fullfile('E:','Matlab\GrainGrowth','grain_nucleus.txt');
fp=fopen(f,'w');
for i=1:s
%    fprintf(fp, '%f,%f,%f\n', x(i), y(i), 0);
   fprintf(fp, '%f %f\n', x(i), y(i));
end
fclose(fp);