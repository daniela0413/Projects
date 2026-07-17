function motor_asincron_sfunc(block)
    setup(block);
end

function setup(block)
    % 2 Intrari: ua, ub
    block.NumInputPorts  = 1;
    block.InputPort(1).Dimensions = 2;
    block.InputPort(1).DirectFeedthrough = false;
    
    % 1 Iesire: n [rot/min]
    block.NumOutputPorts = 1;
    block.OutputPort(1).Dimensions = 1;
    
    % 5 Stari continue: [phi_a, phi_b, ia, ib, omega]
    block.NumContStates = 5;
    
    block.SampleTimes = [0 0]; % Continuu
    
    block.RegBlockMethod('InitializeConditions', @InitializeConditions);
    block.RegBlockMethod('Derivatives',          @Derivatives);
    block.RegBlockMethod('Outputs',              @Outputs);
end

function InitializeConditions(block)
    block.ContStates.Data = zeros(5,1);
end

function Outputs(block)
    x = block.ContStates.Data;
    omega = x(5);
    block.OutputPort(1).Data = (30/pi) * omega;
end

function Derivatives(block)
    J=0.4; Kf=0.1115; Rr=0.156; Rs=0.294;
    Lr=0.0417; Ls=0.0424; LM=0.041; MR=0;
    alpha=Rr/Lr; beta=LM/(Ls*Lr); gamma=1-LM^2/(Ls*Lr);
    
    x = block.ContStates.Data;
    u = block.InputPort(1).Data;
    
    phi_a=x(1); phi_b=x(2); ia=x(3); ib=x(4); omega=x(5);
    ua=u(1); ub=u(2);
    
    dphi_a = -alpha*phi_a - omega*phi_b + LM*alpha*ia;
    dphi_b = -alpha*phi_b + omega*phi_a + LM*alpha*ib;
    dia    = -beta*dphi_a + (1/(gamma*Ls))*(ua - Rs*ia);
    dib    = -beta*dphi_b + (1/(gamma*Ls))*(ub - Rs*ib);
    domega = (1/J)*(LM/Lr)*(phi_a*ib - phi_b*ia) - (Kf/J)*omega - MR/J;
    
    block.Derivatives.Data = [dphi_a; dphi_b; dia; dib; domega];
end
