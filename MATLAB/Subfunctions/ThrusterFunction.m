function [thruster_Name, thruster_Force, mount_angle_xy, power, diameter] = ThrusterFunction(speed)

    speed_si = speed / 1.944; %converts to m/s

    total_drag = getdrag(speed_si);

    [thruster_Name, thruster_Force, mount_angle_xy, power, diameter] = thruster_selection(total_drag);

    function hydrodynamic_drag = getdrag(speed_si)

        %%%%%%%%% CONSTANT PROPERTIES %%%%%%%%%%%%%
        WATER_DENSITY = 997; % /m^3

        HULL_CD = 0.4; % non-dimensional, cd for a sphere
        HULL_RADIUS_OUTER = (2240/2)/1000; % m

        BALLAST_CD = 0.295; %non-dimensional, based on rounded bullet shape
        BALLAST_Radus = 0.425; %m, based on latest rendition we have of design

        %%%%%%%%%% Math %%%%%%%%%%%

        hull_body_drag = .5 * HULL_CD * WATER_DENSITY * (pi * HULL_RADIUS_OUTER^2) * speed_si^2;

        ballast_drag = .5 * BALLAST_CD * WATER_DENSITY * (pi * BALLAST_Radus^2) * speed_si^2;

        total_drag = hull_body_drag + 2 * ballast_drag;

        %%%%%%%%%% OUTPUT %%%%%%%%%%
        hydrodynamic_drag = total_drag; %N
    end

    function [thruster_Name, thruster_Force, mount_angle_xy, thruster_power, diameter] = thruster_selection(total_drag)

        %%%%%%%%%%%% THRUSTER PROPERTIES %%%%%%%%%%%%%%%%
        THRUSTER_VS = 240; % N/thruster
        THRUSTER_VM = 600; % N/thruster
        THRUSTER_VL = 1260; % N/thruster
        THRUSTER_VXL = 2400; % N/thruster

        Thrust_Needed_Per_Thruster = total_drag / 4; %N, because there are four thruster (effective x direction)

        Selection_OT = " ";
        T_ForceMax = 0;
        thruster_angle = 0;

        %%%%%%%%%%%%% THRUST REQUIRMENT CHECK %%%%%%%%%%%

        if Thrust_Needed_Per_Thruster <= 2400
            Selection_OT = "THRUSTER_VXL";
            T_ForceMax = 2400;
            thruster_power = 16;
            diameter = 321;
        end

        if Thrust_Needed_Per_Thruster <= 1260
            Selection_OT = "THRUSTER_VL";
            T_ForceMax = 1260;
            thruster_power = 9;
            diameter = 253;
        end

        if Thrust_Needed_Per_Thruster <= 600
            Selection_OT = "THRUSTER_VM";
            T_ForceMax = 600;
            thruster_power = 5;            
            diameter = 202;
        end

        if Thrust_Needed_Per_Thruster <= 240
            Selection_OT = "THRUSTER_VS";
            T_ForceMax = 240;
            thruster_power = 2.5;
            diameter = 150;
        end

        if Thrust_Needed_Per_Thruster > 2400
            Selection_OT = "No Thruster Meets This Criteria";
            T_ForceMax = 2400;
            thruster_power = 16;
            diameter = 321;
        end

        thruster_angle = (asin(Thrust_Needed_Per_Thruster / T_ForceMax) * 180) / pi;

        %%%%%%%%%%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        thruster_Name = Selection_OT; %Name
        thruster_Force = Thrust_Needed_Per_Thruster; %N
        mount_angle_xy = thruster_angle; % Degrees, Assuming no ZX angle.
    end

end
