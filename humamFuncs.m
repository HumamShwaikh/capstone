function humamFuncs()
%
% description.
%
% @since 1.0.0
% @param {type} [name] description.
% @return {type} [name] description.
% @see dependencies
%    
    
    RADIUS_OUTTER = 1;
    SIGMA_SUSTAINED_ACRYLIC = 10000000;
    SIGMA_ACRYLIC = 2760000000;
    depth = 4500; %Depth is 1000m, this term will be paramaterization value
    %P_depth = pressure_at_depth(depth);
    t = get_thickness(depth);
    t = t*100 + " cm"
    
    
    function output = get_thickness(targetDepth)
        pressure = pressure_at_depth(targetDepth);
        thickness = 0.0001;
        stress = hull_stress(pressure, thickness, RADIUS_OUTTER);
        t_buckle = buckling_thickness(stress,RADIUS_OUTTER,thickness);
        while (t_buckle > thickness) || (SIGMA_SUSTAINED_ACRYLIC < stress)
            thickness = thickness + 0.001;
            stress = hull_stress(pressure, thickness, RADIUS_OUTTER);
            t_buckle = buckling_thickness(stress,RADIUS_OUTTER,thickness);
        end
        output = thickness;
    end
    
    function sigma_hull = hull_stress(p,t,r)
        psi = 0.01;
        theta = 0.01;
        sigma_hull = (p*(t+r)*(t+r)*psi*theta)/(8*((t^2)+2*r*t)*(psi+theta)^2);
    end

    
    function t_buckle = buckling_thickness(stress, r, t)
        p_cr = stress*(t*t);
        t_buckle = ((6*r*r*p_cr)/(SIGMA_ACRYLIC))^0.25;
    end
    
%     function dif = percentDifference(x, y)
%         dif = abs(100*((x-y)/y));  
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Function: pressure_at_depth
    % -------------------------------------------
    % Calculates pressure of water at input depth
    %
    % @params: depth
    %
    % @returns: P_water
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function P_water = pressure_at_depth(depth)
        rho = 1032.85; %density of seawater (kg/m^3)
        g = 9.81; % gravity(m/s)
        P_water = rho * g * depth;
    end
end


