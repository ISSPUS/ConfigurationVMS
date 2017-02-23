 
# Entorno de desarrollo en docker
Aquí se encuentra la imágen para lanzar el entorno de desarrollo en docker.

Para compilar la imágen usar: `docker build . -t shipmee/workspace`


Para ejecutar por primera vez:

```bash
xhost + && docker run --name shipmee-workspace \
    -p 8080:8080 \
    -v my_Local_Workspace:/root/workspace \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v ~/.Xauthority:/home/pebble/.Xauthority \
    shipmee/workspace
```

Para ejecutarlo en el futuro: 

```bash
docker start shipmee-workspace
```
