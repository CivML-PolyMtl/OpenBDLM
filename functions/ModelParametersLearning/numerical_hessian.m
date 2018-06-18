function H=numerical_hessian(x, fX, varargin)
%% Defaut values
delta_diff  = 1E-6*ones(length(x), 1); %relative delta value used for numerical derivatives.
H           = zeros(length(x));

%% if provided, employ user-specific arguments
args    = varargin;
nargs   = length(varargin);
for n = 1:2:nargs
    switch args{n}
        case 'stepSize', delta_diff = args{n+1};
        otherwise, error(['unrecognized argument' args{n}])
    end
end
delta_x     = delta_diff.*x;

for i=1:length(x)
    for j=1:length(x)
             % G1
            delta_xij=x;
            delta_xij(i)=delta_xij(i)+delta_x(i);
            delta_xij(j)=delta_xij(j)+delta_x(j);
            G1=fX(delta_xij);
            
            % G2
            delta_xij=x;
            delta_xij(i)=delta_xij(i)+delta_x(i);
            delta_xij(j)=delta_xij(j)-delta_x(j);
            G2=fX(delta_xij);
            
            % G3
            delta_xij=x;
            delta_xij(i)=delta_xij(i)-delta_x(i);
            delta_xij(j)=delta_xij(j)+delta_x(j);
            G3=fX(delta_xij);
            
            % G4
            delta_xij=x;
            delta_xij(i)=delta_xij(i)-delta_x(i);
            delta_xij(j)=delta_xij(j)-delta_x(j);
            G4=fX(delta_xij);
            
            dGdxp=(G1-G2)/(2*delta_x(j));
            dGdxm=(G3-G4)/(2*delta_x(j));
            
            H(i,j)=(dGdxp-dGdxm)/(2*delta_x(i));
    end
end