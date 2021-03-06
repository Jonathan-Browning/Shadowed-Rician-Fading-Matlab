classdef ShadowedRice
    %SHADOWEDRICE This class holds all the parameters for the shadowed Rician fading model.
    % It calculates theoretical envelope and phase PDFs
    % It does a Monte Carlo simulation using the parameters
    
    properties(Constant, Hidden = true)
        NumSamples = 2E6; % number of samples
        r = 0:0.001:6 % envelope range for PDF ploteter
        theta = -pi:0.001:pi; % phase range for PDF plot
    end 
    
    properties(Access = public)
        K; % Rician K factor
        m; % line of sight shadowing severity
        r_hat; % root mean square of the signal
        phi; % phase parameter
    end
    
    properties(Hidden = true) 
        multipathFading; % Found based on the inputs
        envelopeProbability; % Calculated theoretical envelope probability
        phaseProbability; % Calculated theoretical phase probability
        xdataEnv; % Simulated envelope density plot x values 
        ydataEnv; % Simlated envelope density plot y valyes
        xdataPh; % Simulated phase density plot x values 
        ydataPh; % Simlated phase density plot y valyes
    end
    
    methods(Access = public)
        function obj = ShadowedRice(K,m,r_hat,phi)
            %ADDITIVESHADOWRICE Construct an instance of this class
            
            %   Assigning input values
            obj.K = input_Check(obj,K,'K',0.001,50);
            obj.m = input_Check(obj,m,'m',0.001,50);
            obj.r_hat = input_Check(obj,r_hat,'\hat{r}',0.5,2.5);
            obj.phi = input_Check(obj,phi,'\phi',-pi,pi);
            
            % other calculated properties
            obj.multipathFading = complex_Multipath_Fading(obj);
            obj.envelopeProbability = envelope_PDF(obj);
            obj.phaseProbability = phase_PDF(obj);
            [obj.xdataEnv, obj.ydataEnv] = envelope_Density(obj);
            [obj.xdataPh, obj.ydataPh] = phase_Density(obj);
            
        end
    end
    
    methods(Access = private)
        
        function data = input_Check(obj, data, name, lower, upper) 
            % intput_Check checks the user inputs and throws errors
            
            % checks if input is empty
            if isempty(data)
                error(strcat(name,' must be a numeric input'));
            end
            
            % inputs must be a number
            if ~isnumeric(data)
               error(strcat(name,' must be a number, not a %s.', class(data)));
            end
            
            % input must be within the range
            if data < lower || data > upper
               error(strcat(name,' must be in the range [',num2str(lower),', ',num2str(upper),'].'));
            end
        end
        
        function [p, q] = means(obj)
            %means Calculates the means of the complex Gaussians 
            %representing the in-phase and quadrature components.

            p = sqrt(obj.K/(1+obj.K)) .* obj.r_hat .* cos(obj.phi);
            q = sqrt(obj.K/(1+obj.K)) .* obj.r_hat .* sin(obj.phi);

        end
        
        function [sigma] = scattered_Component(obj)
            %scattered_Component Calculates the power of the scattered 
            %signal component.    
            
            sigma = obj.r_hat ./ sqrt(2 * (1 + obj.K));
        
        end
        
        function [X, Y] = generate_Gaussians(obj, p, q, sigma) 
            %generate_Gaussians Generates the Gaussian random variables 
            
            % generate line of sight shadowing
            xi = sqrt(gamrnd(obj.m,1./obj.m,[1,obj.NumSamples]));
            
            X = normrnd(xi.*p, sigma, [1,obj.NumSamples]);
            Y = normrnd(xi.*q, sigma, [1,obj.NumSamples]);
        end
        
        function [multipathFading] = complex_Multipath_Fading(obj) 
            %complex_MultipathFading Generates the Rician fading model 
            
            [p, q] = means(obj);
            
            [sigma] = scattered_Component(obj);
            
            [X, Y] = generate_Gaussians(obj, p, q, sigma);
            
            multipathFading = X + 1i.* Y;
        end    
        
        function [eProbTheor] = envelope_PDF(obj)
            %envelope_PDF Calculates the theoretical envelope PDF
            
            eProbTheor = 2 .* (1+obj.K) .* obj.r .*(obj.m^(obj.m))./ (obj.r_hat.^(2)*(obj.m+obj.K)^(obj.m)) ...
                .* exp(- ((1+obj.K) .* obj.r.^(2)) ./ obj.r_hat^(2))...
                .* kummer(obj.m, 1, obj.r.^(2).*obj.K.*(obj.K+1)./(obj.r_hat^(2)*(obj.K+obj.m)));
        end
        
        function [pProbTheor] = phase_PDF(obj)
            %envelope_PDF Calculates the theoretical phase PDF
            
            pProbTheor =  (obj.m^obj.m .* sqrt(obj.K)./(2 .* sqrt(pi).* (obj.K + obj.m).^(obj.m +1/2)))...
            .* ( sqrt((obj.K +obj.m)./(pi.*obj.K)) .* hyp2f1(obj.m, 1, 1/2,  (obj.K.*(cos(obj.theta - obj.phi)).^(2))./(obj.K +obj.m))...
            +  ((gamma(obj.m+1/2) ./ gamma(obj.m)).*cos(obj.theta-obj.phi)...
            .* (1-  (obj.K*(cos(obj.theta - obj.phi)).^(2))./(obj.K +obj.m)).^(-obj.m-1/2)));
 
        end
        
        function [xdataEnv, ydataEnv] = envelope_Density(obj)
            %envelope_Density Evaluates the envelope PDF
            R = sqrt((real(obj.multipathFading)).^(2) + (imag(obj.multipathFading)).^(2));

            [f,x] = ecdf(R);
            [ydataEnv, xdataEnv] = ecdfhist(f,x, 0:0.05:max(obj.r));
        end
        
        function [xdataPh, ydataPh] = phase_Density(obj)
            %envelope_Density Evaluates the envelope PDF
            T = angle(obj.multipathFading);

            [f,x] = ecdf(T);
            [ydataPh, xdataPh] = ecdfhist(f,x, min(obj.theta)+0.03:0.06:max(obj.theta));
        end
            
    end
end

