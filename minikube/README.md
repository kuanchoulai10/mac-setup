# [minikube](https://minikube.sigs.k8s.io/docs/)

```
brew install minikube docker kubectl colima
```
- [ ] Create


## Create



```
```


## Enable Registry

https://minikube.sigs.k8s.io/docs/handbook/addons/registry-aliases/


## Colima

Colima is a container runtime on macOS (and Linux) with minimal setup, built on top of Lima. It provides a Docker-compatible CLI and works well with Kubernetes. Basically, Colima runs a lightweight VM on your macOs / Linux machine (managed by Lima) that provides a container runtime environment. When you start Colima, you can choose which "container runtime" to use.

Start colima with more resources:

```bash
colima start \
    --cpu 9 \
    --memory 24 \
    --disk 120 \
    --runtime docker \
    --profile data
    # --disk-image ~/Downloads/ubuntu.qcow2
```

If the disk image is not downloaded automatically, you can download it manually and then specify the path when starting colima via `--disk-image` flag:

```bash
curl -L -o ~/Downloads/ubuntu.qcow2 https://github.com/abiosoft/colima-core/releases/download/v0.8.3/ubuntu-24.04-minimal-cloudimg-arm64-docker.qcow2
```

The command above would first launch a lightweight VM using Lima, then install and start the Docker daemon (`dockerd`) inside that VM. This means you can use Docker commands on your macOS / Linux machine as if you were running them natively, but they are actually being executed inside the VM managed by Colima.

After executing the above command, you should see output like this: 

```bash
colima status -p data

INFO[0000] colima [profile=data] is running using macOS Virtualization.Framework 
INFO[0000] arch: aarch64                                
INFO[0000] runtime: docker                              
INFO[0000] mountType: virtiofs                          
INFO[0000] docker socket: unix:///Users/kcl/.colima/data/docker.sock 
INFO[0000] containerd socket: unix:///Users/kcl/.colima/data/containerd.sock 
```

You can verify that Colima is running and check its status with:

```bash
colima list

PROFILE    STATUS     ARCH       CPUS    MEMORY    DISK      RUNTIME    ADDRESS
data       Running    aarch64    8       24GiB     120GiB    docker     
```

After starting Colima, it would also set up a Docker context named `colima-data` that points to the Docker daemon running inside the Colima VM. You can check your current Docker contexts with:

```bash
docker context ls

NAME            DESCRIPTION                               DOCKER ENDPOINT                              ERROR
colima-data *   colima [profile=data]                     unix:///Users/kcl/.colima/data/docker.sock   
default         Current DOCKER_HOST based configuration   unix:///var/run/docker.sock                  
desktop-linux   Docker Desktop                            unix:///Users/kcl/.docker/run/docker.sock    
```

Start

```bash
minikube config set profile data
minikube config set cpus 3
minikube config set memory 8G
minikube config set disk-size 40G
minikube config set driver docker
minikube config set container-runtime containerd
minikube config set kubernetes-version v1.30.2

minikube config view
minikube status
minikube profile list
docker ps -a

minikube start \
  --nodes 3 \
  --addons registry \
  --delete-on-failure

minikube config view
minikube status
minikube profile list
docker ps -a
```

---

!!! info "`containerd`, `docker`, `dockerd` 的關係？"

    這三個名詞常常混在一起，實際上它們是不同層級的東西，關係有點像「引擎 --> 服務 --> 工具」。我幫你用比較白話、流程化的方式說明：

    **`containerd`**

    - 它是一個 **容器執行引擎 (container runtime)**。
    - 功能就是「幫你負責跑容器」，例如下載映像檔、解壓縮、設定 namespace、建立 cgroups、掛載檔案系統、啟動/停止容器等。
    - `containerd` 不直接面對使用者，而是提供一個 API，讓其他上層的東西（像 Docker 或 Kubernetes）呼叫它。
    - 簡單說：`containerd` = 「低階的容器管理引擎」。

    **dockerd**

    - dockerd 是 **Docker Daemon**（守護程序）。
    - 它是一個「背景服務」，負責接收 `docker` CLI 的指令，並且把這些指令轉換成 `containerd` 可以懂的 API 呼叫。
    - 它還包含一些高階功能：
        - 網路管理（bridge network, overlay network）
        - Volume 資料卷管理
        - BuildKit（建構 image）
        - API Server（讓 CLI 或其他程式溝通）
        - 所以你在打 `docker run nginx`，其實是 CLI --> dockerd --> `containerd` --> Linux kernel。

    **docker**

    - 這就是你在 terminal 打的 **CLI 工具**。
    - 它本身不會直接跑容器，而是把指令送給 dockerd。
    - 例如：
        - `docker ps` --> 去問 dockerd 現在有哪些容器在跑
        - `docker run` --> 叫 dockerd 去用 `containerd` 建立一個新容器
        - 所以 docker CLI 就是「使用者的操作介面」。

    流程可以這樣畫：

    ```
    你 (docker CLI) 
    ↓  發送指令
    dockerd (Docker Daemon, 背景服務)
    ↓  呼叫 API
    `containerd` (容器執行引擎)
    ↓
    Linux Kernel (namespaces, cgroups, overlayfs...)
    ↓
    容器真的在系統上跑起來
    ```


    - 在 **Kubernetes** 世界裡，為了不被綁死在 Docker 上，它改用 CRI (Container Runtime Interface) 標準，直接跟 containerd 或 CRI-O 溝通，所以新版 Kubernetes 其實不需要 dockerd。
    - 這就是為什麼你會聽到「K8s 不再支援 Docker runtime」，但它仍然在用 containerd。

!!! info "打開 Docker Desktop 後，背後發生了什麼事？"

    當你在 macOS 上打開 Docker Desktop，其實背後發生了一連串隱藏的流程。由於 macOS 本身並沒有 Linux kernel，而 Docker 引擎需要依賴 Linux，所以 Docker Desktop 的第一步，就是**在你的電腦上建立一個輕量級的 Linux 虛擬機**。這個虛擬機是透過 Apple 的 Hypervisor.framework 或 Virtualization.framework 啟動的，裡面運行的是一個精簡過的 Linux 系統，專門用來承載 Docker 的運行環境。

    在這個虛擬機內，Docker Desktop 會啟動 **dockerd**，也就是 Docker Daemon，同時搭配 containerd 和 runc 等元件，負責真正建立和管理容器。這個 Docker Daemon 對外提供了一個 API 介面，讓本地的 Docker CLI 或是 Docker Desktop 的圖形化介面能夠與它溝通。當你在終端機裡輸入一個 `docker run` 指令時，實際上是 CLI 經由 Unix socket 將請求轉送到虛擬機內的 Docker Daemon，然後由它來完成容器的建立與啟動。

    為了讓這些容器和你的 macOS 系統更好地整合，Docker Desktop 還處理了幾個重要的橋接功能。它會把你的 macOS 檔案系統，例如 `/Users/你`，掛載到虛擬機內，讓容器能夠讀取或寫入。它也會建立網路轉發與埠對應，確保當容器內有服務在監聽時，你可以直接用 localhost:8080 這樣的方式從 macOS 訪問，而不需要意識到容器實際上是跑在一個虛擬機裡。甚至在你需要的時候，它也能幫你自動啟動一個單節點的 Kubernetes，並且配置好 kubectl 的 context，讓你在本地就能體驗完整的 Kubernetes 環境。

    至於你在 Docker Desktop 的圖形化介面中看到的那些容器、映像檔和 Volume 狀態，其實只是透過 GUI 呼叫 Docker Daemon 的 API，把資訊整理後呈現給你。當你在 GUI 裡調整 CPU、記憶體或磁碟資源時，它背後則是重新設定虛擬機的配置，讓容器運行時有足夠的資源。

    所以說，每當你打開 Docker Desktop，看似只是開啟一個應用程式，實際上卻是先啟動了一個 Linux 虛擬機，再在裡面跑起 Docker Daemon，並建立各種與 macOS 的整合橋樑。從檔案共享到網路轉發，從容器管理到 Kubernetes，所有的便利功能其實都依賴這個隱藏的 VM 運作。換句話說，Docker Desktop 就是一個把 VM、Docker 引擎和系統整合功能封裝起來的解決方案，讓你在 macOS 上能夠近乎無感地使用原本專屬於 Linux 的容器技術。

!!! info "什麼是 `docker context`？"

    - `docker context` 就是 Docker CLI 連到哪一個 Docker daemon 的設定。
    - 每個 context 包含：
        - Daemon endpoint（本地 socket 或遠端 TCP）
        - 預設 namespace / TLS 設定
    - 透過 `docker context` use 可以切換。

    你可以想像：
    
    - docker 指令本身不跑容器，它只是個「遙控器」。
    - `docker context` 就是決定「這個遙控器遙控的是哪台 Docker daemon」。

!!! info "How does Colima compare to minikube, Kind, K3d?"

    See [here](https://github.com/abiosoft/colima/blob/main/docs/FAQ.md#how-does-colima-compare-to-minikube-kind-k3d) for more.

!!! info "Colima 的 containerd 和 docker runtime 的差異？"

    **`containerd`** runtime

    直接使用 `containerd` 作為 runtime，不啟動 `dockerd`。

    好處：

    - 輕量、少一層（沒有 `dockerd`）
    - 跟 Kubernetes（例如 minikube、k3s、kind）原生相容，因為它們直接支援 CRI (Container Runtime Interface)。
    - 少一個守護程式，效能和資源利用率通常更好。
    
    限制：

    - 缺少 Docker CLI 提供的完整體驗，例如 `docker build`、`docker compose`。
    - 雖然還是可以用 `nerdctl` 這類 CLI 操作 `containerd`，但生態系沒有 Docker CLI 那麼成熟。

    適合：Kubernetes 開發（因為 K8s 本來就是呼叫 `containerd`），或想要少一層中介、效能更好的場景。

    **`docker`** runtime

    在 VM 裡啟動 `dockerd` (Docker Daemon)，再由它去呼叫 `containerd`。

    好處：

    - 完整支援 Docker CLI、Docker Compose、生態系（大部分工具還是預設跟 docker 整合）。
    - 對開發者很直覺，因為 docker run、docker ps、docker build 都能直接用。

    限制：

    - 比直接用 containerd 多一層 dockerd --> containerd，稍微重一些。
    - 跟 K8s 的整合不是直接的，而是透過 dockershim 轉手到 containerd（但因為 K8s 已棄用 dockershim，所以長遠來說 containerd 更乾淨）。

    適合：需要 Docker CLI 或 Docker Compose 的開發者，例如本地開發、測試需要大量使用 Docker 生態的情境。
