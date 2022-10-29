#PARADAS =[S1,S2,S3]
set PARADAS;
#ALUMNOS=[A1,A2,A3]
set ALUMNOS;
#PS=[P, S]
set PS;



#Matriz de coses de entrada [pasamos por data set]
param costes{v in PARADAS, w in PARADAS};
#Matriz de costes para PS
param costesPS{v in PS, w in PARADAS};
#Matriz de relacion entre hermanos [pasamos por data set]
param hermanos{v in ALUMNOS, w in ALUMNOS};
#Matriz de Alumnos con las paradas que pueden ir [pasamos por data set]
param ParadaAlumnos{v in ALUMNOS, w in PARADAS};
#Precio por km recorrido
param preciokm;
#Maximo de alumnos por Autobus
param maxbus;
#Precio por Bus
param preciobus;


#Variable asociado a la conexion entre paradas
var c {v in PARADAS, w in PARADAS}>= 0, binary;
#Variable asociado a la conexion entre las paradas y Colegio o Parking
var cps {v in PS, w in PARADAS}>= 0, binary;
#Variable asociado a los alumnos que estan en cada parada
var a {v in ALUMNOS, w in PARADAS}, >=0, binary;
#Variable asociada al numero total de alumnos por parada
var ap {w in PARADAS}, >=0, integer;
#Numero de Autobuses
var bus >=0, integer;



#Definir la funcion de Optimizacion
minimize coste:
	bus*preciobus+(sum{v in PARADAS, w in PARADAS} c[v,w]*costes[v,w ] + sum{h in PS, k in PARADAS} cps[h,k]*costesPS[h,k])*preciokm;

#Restricciones
s.t. mismasSalidasQueEntradas:
	sum{v in PARADAS} cps["P",v] = sum{v in PARADAS} cps["S",v];

#Misma cantidad de autobuses que salidas
s.t. mismosBusesSalida:
	sum{v in PARADAS} cps["P",v] =bus;

#Numero de bus >= Alumnos Totales/Max Alumnos Autobus
s.t. minimoAutobuses:
	bus >= ((sum{v in ALUMNOS} 1)/maxbus);

#Numero de bus <= numero de paradas
s.t. maxAutobuses:
	bus <= sum{v in PARADAS} 1 ;

#En caso de que en la parada haya algun alumno, existe alguna salida para esa parada
s.t. max_salida {i in PARADAS} :
	(sum{j in PARADAS} (c[i,j])) + cps["S",i] >= -ap[i];

#En caso de que en la parada haya algun alumno, existe alguna llegada a esa parada
s.t. max_llegada {j in PARADAS} :
	(sum{i in PARADAS} (c[i,j])) + cps["P",j] >= -ap[j];

#Misma cantidad de salida que de entrada en cada Parada
s.t. LlegadaSalida{j in PARADAS} :
	(sum{i in PARADAS} (c[i,j])) + cps["S",j] - cps["P",j] - (sum{i in PARADAS} (c[j,i])) = 0 ;

#Si son Hermanos van a la misma parada
s.t. hermanosMismaP {v in ALUMNOS, w in ALUMNOS} :
	2*hermanos[v,w]<= sum{k in PARADAS} ParadaAlumnos[v,k]*(a[v,k]+a[w,k]);

#Cada Alumno solo tiene 1 parada
s.t. NoDosEnMismaParada {w in ALUMNOS}:
	sum {v in PARADAS} a[w,v] = 1;

#La suma de todos los alumnos de cada parada
s.t. SumaAlumnosParada {w in PARADAS}:
	sum {v in ALUMNOS} a[v,w] = ap[w];

#Los Alumnos solo pueden ir a las Paradas que tienen habilitadas
s.t. ParadasDisponibles {v in ALUMNOS, k in PARADAS}:
	ParadaAlumnos[v,k] * a[v,k] = a[v,k];

#No mas de MAXBUS alumnos en cada parada
s.t. NoMasDeMaxAlumnos {v in PARADAS}:
	ap[v] <= maxbus;

end;
