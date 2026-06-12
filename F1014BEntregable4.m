%% El BONITO
% F1014B Entregable 4

%% Definir metodo de integración
fprintf('Métodos de integración:\n')
fprintf('  1.Euler\n')
fprintf('  2. Runge-Kutta 2do orden\n')
fprintf('  3. Runge-Kutta 4do orden\n')
metodo = input('Elige un método: ');

%% parametros y cosas que no cambian
%etapa 3 cables
numero_cables = 16;

%intentos es el contador de veces que se activa el sistema de recuperación
intentos=0;

%etapa 1
numero_cargas =numero_cables;
%cargas negativas
%nota: Siempre debe tener el mismo signo de la partícula que se mueve
coulomb_carga=1e-6; 

%parametros etapa 2
%campo contante en teslas
%nota: estaba en 0.5 pero lo cambie
B_uniforme= 2;

%parametros etapa 3
radio_toroide = 0.1;
porcentaje_dibujar = 0.8;
radio_dibujar = radio_toroide * porcentaje_dibujar;
porcentaje_r_limite = porcentaje_dibujar*0.6; % el 60% del radio  para comprobar que si se enciende la contención  
radio_limite = radio_toroide * porcentaje_r_limite; 
%radio_limite=0.02;

corriente_estatica =  1000;
corriente_rescate = 5000;

% posicion y velocidad inciial 
r0  = [0.01, 0];  % podemos probar con valores  mas alejados del centro para comprobar que funciona el confinamiento 
dir = rand * 2*pi;
%nota: era 1e3 pero lo cambie para mejor confinamiento
vi  = 1e7 ; %% lo probé hasta con e7 que es 3.3% de la vleocidad de la luz y si jalo entonces lo veo bien
v0  = [vi*cos(dir), vi*sin(dir)];

%parametros de la simulacion
%nota: se hizo un dt más pqueño ya que era muy grande para las fuerzas
% dt tiene que ser mucho menor que el periodo de larmor 
%involucradas
dt=1e-10;
%nota 2: ademas, se va a cambior por otro dt al momento de integrar para
%que cuando se active el control tengamos un dt más fino
pasos=5000000;

radio=zeros(pasos+1, 2);
v =zeros(pasos+1, 2);
radio(1,:)=r0;
v(1,:) =v0;

%constantes
%carga del proton
q= 1.6e-19;
%masa del proton
m= 1.67e-27;
%miu cero
miu0 = 4*pi*1e-7;
%constante electrica
ke = 8.99e9;



%% Etapa Coulombiana (Atrapamiento Electrico)


% Se calculan donde estan las cargas
angulos_cargas = linspace(0, 2*pi, numero_cargas+1);
angulos_cargas(end) = [];
% Calcular las posiciones 
x_cargas = radio_toroide * cos(angulos_cargas);
y_cargas = radio_toroide * sin(angulos_cargas);

%creamos una funcion para la fuerza electrica (asi podemos usarla varias veces en el loop)
% update: se movia la funcion al final porque daba un error, parece que las
% funciones locales van al final


%% Etapa de Larmor (Atrapamiento Magnético Pasivo) (Entrega 2)
%En el loop


%% Etapa de Ampere (Entrega 3)
% posiciones de los cables
angulos_cables = linspace(0, 2*pi, numero_cables+1);
angulos_cables(end) = [];
x_cables = radio_toroide * cos(angulos_cables);
y_cables = radio_toroide * sin(angulos_cables);

%% Definimos figura
%( La definimos aqui porque los loops van a ir dibujando encima)
% nota: esto estaba más arriba pero se movio ya que no se mostraban las
% figuras
figure('Color','k')
hold on
grid on
axis equal
xlim([-0.12 0.12])
ylim([-0.12 0.12])

theta_circulo = linspace(0, 2*pi, 200);

% Dibujamos el circulo limite
plot(radio_limite*cos(theta_circulo), radio_limite*sin(theta_circulo), 'r--', 'LineWidth', 1.5);
% circulo de dibujo
plot(radio_dibujar*cos(theta_circulo), radio_dibujar*sin(theta_circulo), 'r-',  'LineWidth', 1.5);
% circulo grande toroide
plot(radio_toroide*cos(theta_circulo), radio_toroide*sin(theta_circulo), 'w-',  'LineWidth', 1.5);

% dibujamos cargas electricas
for i = 1:numero_cargas
    plot(x_cargas(i), y_cargas(i), 'c+', 'MarkerSize', 6, 'LineWidth', 1.5);
end

%dibujamos los cables en gris
hCables = zeros(1, numero_cables);
for i = 1:numero_cables
    hCables(i) = plot(x_cables(i), y_cables(i), 'wo', ...
        'MarkerFaceColor', [0.3 0.3 0.3], 'MarkerSize', 10);
end

% corriente
I = ones(1, numero_cables) * corriente_estatica;

% tray para dibujar mejor 
tray = animatedline('Color','b');

%% PRUEBAS 
%{
r_larmor = m * vi / (q * B_uniforme);
fprintf('Radio de Larmor: %.4f m\n', r_larmor)
fprintf('Radio del reactor: %.4f m\n', radio_toroide)
fprintf('Relacion r_larmor/reactor: %.2f\n', r_larmor/radio_toroide)

%}

%% Loop principal
try
    % un try porque si cierras el programa antes de que se acaben lso pasos
    % aparece un error y no me gusta
    for n=1:pasos
        %se calcula la dsitancia de la particula al centro
        distancia_centro=norm(radio(n,:));
        activo=distancia_centro >radio_limite; %cambié esta parte para contar  la cantidad de veces que se activa y siempre comprobarlo 
        % control activo (etapa 3/entregable 3)
        
        % Siempre reseteamos primero las corrientes
        I = ones(1, numero_cables) * corriente_estatica;

        %si la distancia del centro es mayor al radio limite se activa
        if activo
            intentos=intentos+1;
            % update: se ajusta dt para que mientras el control activo este
            % presnete tengamo un dt mas fino
            dt_efectivo = dt*0.1;

            %busca el cable mas cercano dependiendo del angulo
            angulo = atan2(radio(n,2), radio(n,1));
            %for si es cero
            if angulo < 0 
                angulo = angulo + 2*pi; 
            end
            
            % Mejor forma de encontrar el cable más cercano angularmente
            % antes se celculaba de forma mas dificil
        
            difAng = abs(atan2(sin(angulos_cables - angulo), cos(angulos_cables - angulo)));
 
            [~, cable_mas_cercano] = min(difAng);
            %se buscan los dos cables a un lado
            cable_izq = mod(cable_mas_cercano-2, numero_cables) + 1;
            cable_der = mod(cable_mas_cercano,   numero_cables) + 1;
            
            %se aplican las correintes de rescate (menor para los de aun lado)
            %update: se hace gradualmente

            I(cable_mas_cercano) = corriente_rescate;
            I(cable_izq) = corriente_rescate*0.5;
            I(cable_der) = corriente_rescate*0.5;
            
            %shapes and colors ~
            set(hCables, 'MarkerFaceColor', [0.3 0.3 0.3]);
            set(hCables(cable_mas_cercano), 'MarkerFaceColor', 'r');
            set(hCables([cable_izq cable_der]), 'MarkerFaceColor', [1 0.5 0]);
        else
            dt_efectivo = dt;
            set(hCables, 'MarkerFaceColor', [0.3 0.3 0.3]);            
            
        end

        % campo magentico por cables (etapa 3) + campo uniforme larmor(etapa 2)
        B_z=B_uniforme;

        for i = 1:numero_cables
            %calcular distancia (componentes x/y)
            dx_c = radio(n,1) - x_cables(i);
            dy_c = radio(n,2) - y_cables(i);

            %distancia
            dist = sqrt(dx_c^2 + dy_c^2+ 1e-10);
           
            %sentido de la corriente
            %si el cable es par el residuo es 0
            if mod(i,2) == 0
                corriente = I(i);
            else
                %cable impar
                corriente = -I(i);
            end
            % asi los calbles alternan sentido de corriente
            
            %se suma la contribucion al campo con la formula de biot-svaar
            
            B_z = B_z + (miu0 * corriente) / (2*pi*dist);
        end

        %Fuerza de lorentz expreimentada
        a_x = (q * v(n,2) * B_z) / m;
        a_y = -(q * v(n,1) * B_z) / m;

        % fuerza de coulomb (usando la fucnión ya hecha)
        F_elec = fuerza_electrica(radio(n,:), x_cargas, y_cargas, coulomb_carga, q, ke);

        %aceleracion
        a = [a_x + F_elec(1)/m,  a_y + F_elec(2)/m];

        % Integración (cambia
        switch metodo
            % Euler
            case 1
                radio(n+1,:)=radio(n,:)+v(n,:)*dt_efectivo;
                v(n+1,:)= v(n,:)+ a*dt_efectivo;
            
            % RK 2do orden
            case 2
                %derivada de la poscion
                k1_r = v(n,:);
                %derivada de la velocidad
                k1_v = a;
                
                %prediccion usando euler (vemos donde esta despues de dt)
                r_pred = radio(n,:) + k1_r*dt_efectivo;
                v_pred = v(n,:)     + k1_v*dt_efectivo;
                
                %calculamos el campo magentico en la poscion especificada
                Bz_pred = B_uniforme;

                %integramos la contribucion de todos los cables
                for i = 1:numero_cables
                    %se encuentar la distancia del lugar al cable
                    dx_c = r_pred(1) - x_cables(i);
                    dy_c = r_pred(2) - y_cables(i);
                    dist = sqrt(dx_c^2 + dy_c^2 +1e-10);
                   
                    % se hacen correintes alternadad
                    if mod(i,2)==0 
                        corriente = I(i); 
                    else 
                        corriente = -I(i);
                    end

                    %campo generado (formula)
                    Bz_pred = Bz_pred + (miu0*corriente)/(2*pi*dist);
                end
                
                %Formula RK                                     (Gracias clase de Matlab por:)
                F_elec_pred = fuerza_electrica(r_pred, x_cargas, y_cargas, coulomb_carga, q, ke);
                k2_r = v_pred;
                k2_v = [(q*v_pred(2)*Bz_pred)/m + F_elec_pred(1)/m,-(q*v_pred(1)*Bz_pred)/m + F_elec_pred(2)/m];
                % (q*v_pred(2)*Bz_pred) y -(q*v_pred(2)*Bz_pred) aparecen por lafuerza de lorentz q(vXB)
                
                % se actualizan posicion y velocidad
                radio(n+1,:)=radio(n,:)+0.5*(k1_r + k2_r)*dt_efectivo;
                v(n+1,:)= v(n,:)+ 0.5*(k1_v + k2_v)*dt_efectivo;

            %RK4
            case 3
                % estado incial de nuevo
                k1_r = v(n,:);
                k1_v = a;
 
                % k2 (se calcula el punto medio con la formula de RK4)
                r2 = radio(n,:) + k1_r*(dt_efectivo/2);
                v2 = v(n,:)+ k1_v*(dt_efectivo/2);

                %inicializamos el campo mágnetico
                Bz2 = B_uniforme;
                  %por cada cable
                for i = 1:numero_cables
                    %diferencia de x/y usando la posicion de r2
                    dx_c = r2(1)-x_cables(i); 
                    dy_c = r2(2)-y_cables(i);
                    %distancia
                    dist = sqrt(dx_c^2+dy_c^2 + 1e-10); 
                  
                    %alternamos las corrientes
                    if mod(i,2)==0
                        corriente=I(i); 
                    else
                        corriente=-I(i); 
                    end

                    % se recalcula el campo en este punto
                    Bz2 = Bz2 + (miu0*corriente)/(2*pi*dist);
                end
                %ahora tenemos la fuerza electrica en r2
                F2 = fuerza_electrica(r2, x_cargas, y_cargas, coulomb_carga, q, ke);
                %pendiente de posicon para k2
                k2_r = v2;
                %pendiente velocidad
                k2_v = [(q*v2(2)*Bz2)/m+F2(1)/m, -(q*v2(1)*Bz2)/m+F2(2)/m];
 
                % k3
                %posicion estimada
                r3 = radio(n,:)+ k2_r*(dt_efectivo/2);
                % v estimada
                v3 = v(n,:)+ k2_v*(dt_efectivo/2);

                %resetamos el campo magnetico
                Bz3 = B_uniforme;


                for i = 1:numero_cables
                    %caclulo de distancias por milesima vez :P
                    dx_c = r3(1)-x_cables(i); 
                    dy_c = r3(2)-y_cables(i);
                    dist = sqrt(dx_c^2+dy_c^2+1e-10); 
                    
                    %corrientes alternas
                    if mod(i,2)==0
                        corriente=I(i); 
                    else 
                        corriente=-I(i); 
                    end
                    %se acutliza la contribucion de este cable al campo
                    Bz3 = Bz3 + (miu0*corriente)/(2*pi*dist);
                end
                %funcion de arriba
                F3 = fuerza_electrica(r3, x_cargas, y_cargas, coulomb_carga, q, ke);
                
                %pendientes nuevas
                k3_r = v3;
                k3_v = [(q*v3(2)*Bz3)/m+F3(1)/m, -(q*v3(1)*Bz3)/m+F3(2)/m];
 
                % k4
                %psocion final estimada
                r4 = radio(n,:) + k3_r*dt_efectivo;
                %v final estimada
                v4 = v(n,:) + k3_v*dt_efectivo;

                %reset
                Bz4 = B_uniforme;



                for i = 1:numero_cables
                    % d i s t a n c i a
                    dx_c = r4(1)-x_cables(i); 
                    dy_c = r4(2)-y_cables(i);
                    dist = sqrt(dx_c^2+dy_c^2+ 1e-10); 

                    % c o r r i e n t e s  a l t e r n a s
                    if mod(i,2)==0 
                        corriente=I(i); 
                    else 
                        corriente=-I(i); 
                    end
                    
                    %actualizamos campo
                    Bz4 = Bz4 + (miu0*corriente)/(2*pi*dist);
                end
                %fuerza electricidad
                F4 = fuerza_electrica(r4, x_cargas, y_cargas, coulomb_carga, q, ke);
                %pendiente final
                k4_r = v4;
                %pendiente velocidad
                k4_v = [(q*v4(2)*Bz4)/m+F4(1)/m, -(q*v4(1)*Bz4)/m+F4(2)/m];
                
                %actualización final de posición
                radio(n+1,:) = radio(n,:) + (dt_efectivo/6)*(k1_r + 2*k2_r + 2*k3_r + k4_r);
                v(n+1,:) = v(n,:)+ (dt_efectivo/6)*(k1_v + 2*k2_v + 2*k3_v + k4_v);

        end

       
        % la velocidad no aumenta por el modelo fisico, sino porerrores de
        % truncamiento de la sintegrales, en la vida real se conserva, por
        % lo tanto pongo este limitante

        % Animación
        %nota: se cambio para visualizar mejor
        %ahora no dibuja todo de nuevo
        if mod(n, 10) == 0
            % add headscatter o addhead
            addpoints(tray, radio(n,1), radio(n,2));
            drawnow limitrate
            %head=scatter2(putnos de arriba,10, filled)

        end

        % VERIFICADOR DE VELOCIDAD PORQUE SIGUE AVANZANDO

        if mod(n, 10000) == 0
            fprintf('paso %d | r=%.4f | |v|=%.2f\n', n, distancia_centro, norm(v(n,:)));
        end        

    end

    title('Entregable 4: Confinamiento  completo (Coulomb, Larmor,Ampere)')
    xlabel('x(m)')
    ylabel('y(m)')
catch
    fprintf("Terminado :) ")
    disp("Pasos de control :"+intentos)
end




%% Funcion fuerza electrica (PArte de Etapa 1)
%creamos una funcion para la fuerza electrica (asi podemos usarla varias veces en el loop)

function F = fuerza_electrica(pos, x_cargas, y_cargas, coulomb_carga, q, ke)
    F = [0, 0];
    for i = 1:length(x_cargas)
        dx = pos(1) - x_cargas(i);
        dy = pos(2) - y_cargas(i);
        % pequeña cantidad al final para evitar errores (visto en el modulo pasado)
        r = sqrt(dx^2 + dy^2 +1e-10);
        F_mag = ke * q * coulomb_carga / r^2;
        %actualizamos fuerzas
        F(1) = F(1) + F_mag * (dx/r);
        F(2) = F(2) + F_mag * (dy/r);
    end
end