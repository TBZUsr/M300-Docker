# M300-Docker

## Servicebeschreibung

Für den Docker teil habe ich zwei Services gemacht, welche ihre Daten auf dem gleichen Datenbankserver abspeichern.
Beide Services und auch der Datenbank Server speichern Ihre Daten und Konfigurationen in persistenten Volumes ab.

<br>

### MySQL

For PostgreSQL wollte ich MySQL als Datenbank für Nextcloud und GitLab nutzen.
Nachdem MySQL fertig war, musste ich feststellen, das GitLab, MySQL nicht wirklich unterstützt und es viel einfacher ist, PostgreSQL zu verwenden.

<br>


### PostgreSQL

PostgreSQL ist der Datenbank Server. Ich habe aus dem Dockerhub ein fertiges Image genommen und state den Service mittels Docker-Compose.
Beim Start des Containers wird ein Netzwerk hinzugefügt:
- InternalNetwork (Backend)

Neben den Netzwerken wird auch ein Init.sh Script geladen, damit die Datenbanken und User für Nextcloud und GitLab erstellt werden.
Damit die Daten persistent sind, werden die Datenbanken auf ein attachtes Volume gespeichert.

<br>


### GitLab

GitLab war der zweite Service, welchen ich zum laufen bringen wollte.
GitLab habe ich auch als vollständiges Image aus dem DockerHub heruntergeladen und mittels Docker-Compose gestartet.
Beim Start des Containers werden zwei Netzwerke hinzugefügt:
- InternalNetwork (Backend)
- Bridge (Frontend)

Um den Service zu konfigurieren, müssen alle wichtigen Parameter in einer Umgebungsvariablen hinterlegt werden.
Damit die Daten persistent sind, werden die Daten und Konfigurationen auf attachte Volumes 
gespeichert.

<br>


### Nextcloud

Nextcloud habe ich selber mit einem Dockerfile erstellt.
Beim builden des Containers werden Apache, PHP und weitere bennötigte abhängigkeiten installiert und konfiguriert.
Nach der Konfiguration wird Nextcloud heruntergeladen, entpackt und die entsprechenden Berechtigungen gesetzt.
Beim Builden des Containers werden zwei Netzwerke hinzugefügt:
- InternalNetwork (Backend)
- Bridge (Frontend)

Damit die Daten persistent sind, werden die Daten und Konfigurationen auf attachte Volumes gespeichert.
Biem Start des Containers wird, falls noch nicht vorhanden, die Datenbank initialisiert.
Falls dies bereits getant wurde, wird lediglich wieder alles geladen.

<br>


# Volumes

## MySQL

**Datenbank Daten**

    docker volume create    --driver local \
                            --label MySQLDataVol \
                            --opt type=ext4 \
                            --opt device=:/Docker/MySQL/Volumes/Data \
                            mysqldata-vol


## PostgreSQL

**Datenbank Daten**

    docker volume create    --driver local \
                            --label PostgresDataVol \
                            --opt type=ext4 \
                            --opt device=:/Docker/Postgres/Volumes/Data \
                            postgresdata-vol


## Nextcloud

**Daten**

    docker volume create    --driver local \
                            --label NextcloudDataVol \
                            --opt type=ext4 \
                            --opt device=:/Docker/Nextcloud/Volumes/Data \
                            nextclouddata-vol
							

**Konfigurationen**

    docker volume create    --driver local \
                            --label NextcloudConfigVol \
                            --opt type=ext4 \
                            --opt device=:/Docker/Nextcloud/Volumes/Config \
                            nextcloudconfig-vol


## GitLab

**Konfiguration**

    docker volume create    --driver local \
                            --label GitHubConfigVol \
                            --opt type=ext4 \
                            --opt device=:/Docker/GitLab/Volumes/Config \
                            gitlabconfig-vol

    docker volume create    --driver local \
                            --label GitHubLogsVol \
                            --opt type=ext4 \
                            --opt device=:/Docker/GitLab/Volumes/Logs \
                            gitlablogs-vol


    docker volume create    --driver local \
                            --label GitHubDataVol \
                            --opt type=ext4 \
                            --opt device=:/Docker/GitLab/Volumes/Data \
                            gitlabdata-vol
							
<br>


# Testfälle

| Service | Testfall | Resultat |
|:--:|:--|:--|
Nextcloud | Der Webserver erzwingt eine HTTPS verbindung unter 192.168.10.66:8081. | SSL Verbindung wurde erzwungen und funktioniert.
Nextcloud; PostgreSQL | Mittels dem Benutzer "admin" und dem Passwort "Test1234" kann man sich unter 192.168.10.66:8081 einloggen. | Login war erfolgreich.
Nextcloud; PostgreSQL | Dateien, welche hochgeladen werden, sind nach einem ``docker-compose down && docker-compose up -d`` immernoch vorhanden. | Dateien waren immernoch vorhanden.
GitHub; PostgreSQL | Login unter 192.168.10.66 ist mit dem Benutzer "root" und dem Passwort "Test1234" möglich. |Login war erfolgreich.
GitHub; PostgreSQL | Änderungen in GitHub sind nach ``docker-compose down && docker-compose up -d`` immernoch vorhanden. | Einstellungen waren immernoch gesetzt.

<br>

# Einrichtung in Docker umgebung

Um die Docker-Compose Datei selber verwenden zu können, wird folgendes bennötigt:

**Ubuntu 1804 Server**
- mindestens 4GB Ram
- mindestens 16GB Festplattenspeicher
- mindestens 1 CPU

Die Datei "Docker" muss im Root-Verzeichis liegen (/Docker). Es müssen vor dem Start von Docker-Compose die Volumes erstellt werden. Die erstellung der Volumes sind unter [Volumes](#Volumes) beschrieben. Damit man auf die Webservices über die Host IP zugreiffen kann, muss man in der Datei ``/Docker/Compose/docker-compose.yml`` unter der GitLab konfiguration die IP von "192.168.10.66" auf die Host IP des Docker Servers ändern. Dies muss auch in der Datei ``/Docker/Nextcloud/Scripts/NextcloudStart.sh`` getant werden.

Nachdem die Umgebung vorbereitet wurde, kann man in das Verzeichnis "/Docker/Compose" navigieren und die drei Services mittels ``docker-compose up -d`` builden und starten.

Die Services sind nach etwa 5 Minuten fertig erstellt (GitLab bennötigt eher lange).

GitLab ist unter "HostIP":8082 erreichbar. Nextcloud HTTP unter "HostIP":8080 und HTTPS unter "HostIP":8081

<br>

# Netzwerkplan

![Netzwerkplan](Netzwerkplan.png)

# Kubernetes
Neben Docker habe ich auch noch Kubernetes ausprobiert. Ich habe es nach längerem Debuggen geschaft zwei Ubuntu Hosts in Kubernetes zu verbinden, zwei NginX Webserver instanzen darauf laufen zu lassen, diese mittels eines Loadbalancer Services auf Port 80 zu exposen und alles visuel im Kuberneses-Dashboard anzeigen zu lassen.

Das Kubernetes-Dashboard konnte ich auch von ausserhalb zugreifbar machen und ich habe auch einen "Benutzer" mit eigenem Tocken erstellt, welcher auf das Kubernetes-Dashboard mit allen rechten kommt.

<br>

<br>

**Kubernetes Installieren**

    ## On Slave and Master ##
    # Turn swap off
    swapoff -a

    nano /etc/fstab

    # Comment the swap line

    apt-get update && apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb https://apt.kubernetes.io/ kubernetes-xenial main
    EOF
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    systemctl daemon-reload
    systemctl restart kubelet

**Cluster erstellen**

    ## On Master ##
    # Initialize Kubeadm
    kubeadm init --pod-network-cidr=10.244.0.0/16

    # Add Flannel network
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

    # Configure user
    # Exir root first!!
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    ## On Slave ##
    # Joind the master
    # The token, hash, master ip and port are listed on the terminal
    kubeadm join --token <token> <master-ip>:<master-port> --discovery-token-ca-cert-hash sha256:<hash>

<br>
