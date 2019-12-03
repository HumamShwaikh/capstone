function humamFuncs()
%
% description.
%
% @since 1.0.0
% @param {type} [name] description.
% @return {type} [name] description.
% @see dependencies
%    
    ACRYLIC_DENSITY = 1180; %kg/m^3
    RADIUS_OUTTER = 1; %m
    SIGMA_SUSTAINED_ACRYLIC = 10000000;%Pa
    SIGMA_ACRYLIC = 2760000000; %Pa
    HATCH_HOLE_RADIUS = 0.3; %m
    UTS_STAINLESS_STEEL = 448000000; %Pa
    depth = 4500; %Depth is 1000m, this term will be paramaterization value
    %P_depth = pressure_at_depth(depth);
    [hullVolume, hullMass, hullThickness] = get_hull_thickness(depth);
    "Hull Thickness: "+hullThickness*100 + " cm";
    "Hull Volume: " +hullVolume + " m^3";
    "Hull Mass: " + hullMass + " kg";
    hatchThickness = get_hatch_thickness(hullThickness, depth);
    "Hatch Thickness: " + hatchThickness*100 + " cm"
    
    function output = get_hatch_thickness(hullThickness, depth)
        p = pressure_at_depth(depth);
        t = 0.001;
        maxStress = UTS_STAINLESS_STEEL+1;
        while maxStress > UTS_STAINLESS_STEEL
            t = t + 0.0001;
            maxStress = (p*(hullThickness*0.707+HATCH_HOLE_RADIUS)^2)/((2*0.707)*(HATCH_HOLE_RADIUS)*t);
        end
        output = t;
    end
    
    function [v_out, m_out, t_out] = get_hull_thickness(targetDepth)
        pressure = pressure_at_depth(targetDepth);
        thickness = 0.0001;
        stress = hull_stress(pressure, thickness, RADIUS_OUTTER);
        t_buckle = buckling_thickness(stress,RADIUS_OUTTER,thickness);
        while (t_buckle > thickness) || (SIGMA_SUSTAINED_ACRYLIC < stress)
            thickness = thickness + 0.001;
            stress = hull_stress(pressure, thickness, RADIUS_OUTTER);
            t_buckle = buckling_thickness(stress,RADIUS_OUTTER,thickness);
        end
        m_out = ((4/3)*3.14*RADIUS_OUTTER^3 - (4/3)*3.14*(RADIUS_OUTTER-thickness)^3)*ACRYLIC_DENSITY;
        v_out = (4/3)*3.14*RADIUS_OUTTER^3;
        t_out = thickness;
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


