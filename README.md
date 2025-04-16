# Memcached

## Build
Note : depend de buildx (cross platform build) & la VM de base Debian Bookworm.

### Les fichiers
- DockerFileemcached : le dockerfile... pour lancer le build
- install-memcached.sh : fichier d'install de l'image. Il est copie et execute dans l'image pendant le build (juste apt-get install memcached dans ce cas)
- ./need_rebuild.sh : script qui permet de checker les modification et rebuilder au cas ou, si il y a eu des modifications ou des packages � updater. possiblement automatisable periodiquement.


### Build : 

#### Build de test : 
```
docker build --no-cache -f DockerFileMemcached -t monimagedetest .
```
... et ensuite, on peut la run

PS : penser à tout cleaner prune & co avant de lancer le build final.


#### Build final, pushé sur le repo : 
```
docker buildx build --no-cache --platform linux/amd64,linux/arm64 -f DockerFileMemcached -t crbrdocker/memcached . --push
```
Attention, il faut le lancer imperativement dans le repertoire ici, sinon des problemes de path
(note, on doit le pusher avec buildx directement, sinon ca ne met pas l'image a dispo, ca la laisse juste dans le cache de build)

#### Automatisation build :
le script ./need_rebuild.sh peut tout faire. Il faut le lancer imperativement dans le repertoire ici, sinon des problemes de path



## Utilisation
Juste docker run ... 

2 variables d'environnement possible au run : 
- MEM : mémoire max (en Mo) allouée à memcache pour ses objets (defaut : 256)
- MAXCONN : nombre max de connexions simultanées (defaut : 1000)
