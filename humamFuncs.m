function humamFuncs()
%
% description.
%
% @since 1.0.0
% @param {type} [name] description.
% @return {type} [name] description.
% @see dependencies
%   
    PI = 3.14159265359;
    ROOT_2 = 1.41421356237;
    EPDM_YOUNGS_MODULUS = 6000000; % Pa
    GASKET_COMPRESSION_RATIO = 0.2;
    SAFETY_FACTOR_HULL = 3;
    SAFETY_FACTOR_HATCH = 3;
    ACRYLIC_DENSITY = 1180; %kg/m^3
    RADIUS_OUTTER = 1; %m
    SIGMA_SUSTAINED_ACRYLIC = 10000000;%Pa
    ELASTIC_MODULUS_ACRYLIC = 2760000000; %Pa
    HATCH_HOLE_RADIUS = 0.3; %m
    UTS_STAINLESS_STEEL = 448000000; %Pa
    ELASTIC_MODULUS_SS = 193000000000; %Pa
    
    depth = 1000; %Depth is 1000m, this term will be paramaterization value
    %P_depth = pressure_at_depth(depth);
    [hullVolume, hullMass, hullThickness] = get_hull_thickness(depth);
    "Hull Thickness: "+hullThickness*100 + " cm"
    "Hull Volume: " +hullVolume + " m^3";
    "Hull Mass: " + hullMass + " kg";
    hatchThickness = get_hatch_thickness(hullThickness, depth);
    "Hatch Thickness: " + hatchThickness*100 + " cm"
    gasketForce = get_sealing_force(0.08, 0.1, 0.0032, GASKET_COMPRESSION_RATIO, EPDM_YOUNGS_MODULUS);
    "Gasket Force: " + gasketForce + " N";
    
    function sealingForce = get_sealing_force(innerDiameter, outerDiameter, restingThickness, compressionPercent, youngsModulus)
        compressedThickness = restingThickness - restingThickness*compressionPercent;
        area = (PI/4)*(outerDiameter^2 - innerDiameter^2);
        deltaL = restingThickness - compressedThickness;
        sealingForce = (area*youngsModulus*deltaL)/restingThickness;
    end
    
    function output = get_hatch_thickness(hullThickness, targetDepth)
        targetDepth = targetDepth * SAFETY_FACTOR_HATCH;
        p = pressure_at_depth(targetDepth);
        t = 0.001;
        maxStress = UTS_STAINLESS_STEEL+1;
        while (maxStress > UTS_STAINLESS_STEEL) || (buckling_thickness(maxStress,RADIUS_OUTTER,t,ELASTIC_MODULUS_SS) > t)
            t = t + 0.0001;
            maxStress = (p*(hullThickness*(ROOT_2/2)+HATCH_HOLE_RADIUS)^2)/((2*(ROOT_2/2))*(HATCH_HOLE_RADIUS)*t);
        end
        buckling_thickness(maxStress,RADIUS_OUTTER,t,ELASTIC_MODULUS_SS)*100
        output = t;
    end
    
    function [v_out, m_out, t_out] = get_hull_thickness(targetDepth)
        targetDepth = targetDepth * SAFETY_FACTOR_HULL;
        pressure = pressure_at_depth(targetDepth);
        thickness = 0.0001;
        stress = hull_stress(pressure, thickness, RADIUS_OUTTER);
        t_buckle = buckling_thickness(stress,RADIUS_OUTTER,thickness,ELASTIC_MODULUS_ACRYLIC);
        while (t_buckle > thickness) || (SIGMA_SUSTAINED_ACRYLIC < stress)
            thickness = thickness + 0.001;
            stress = hull_stress(pressure, thickness, RADIUS_OUTTER);
            t_buckle = buckling_thickness(stress,RADIUS_OUTTER,thickness,ELASTIC_MODULUS_ACRYLIC);
        end
        m_out = ((4/3)*PI*RADIUS_OUTTER^3 - (4/3)*PI*(RADIUS_OUTTER-thickness)^3)*ACRYLIC_DENSITY;
        v_out = (4/3)*PI*RADIUS_OUTTER^3;
        t_out = thickness;
    end
    
    function sigma_hull = hull_stress(p,t,r)
        psi = 0.01;
        theta = 0.01;
        sigma_hull = (p*(t+r)*(t+r)*psi*theta)/(4*((t^2)+2*r*t)*(psi+theta)^2);
    end

    
    function t_buckle = buckling_thickness(stress, r, t,sigma)
        p_cr = stress*(t*t);
        t_buckle = ((6*r*r*p_cr)/(8*sigma))^0.25;
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


