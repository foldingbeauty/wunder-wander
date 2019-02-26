

![alt text](https://github.com/foldingbeauty/wunder-wander/blob/master/frontend/public/assets/images/logo.png "Logo Wunder-Wander Gitops")


An easy to use GitOps deployment tool for Kubernetes workloads.

## Quality
[![Maintainability](https://api.codeclimate.com/v1/badges/1a75cf1d0c809b33d08f/maintainability)](https://codeclimate.com/github/foldingbeauty/wunder-wander/maintainability)
[![CircleCI](https://circleci.com/gh/foldingbeauty/wunder-wander/tree/master.svg?style=svg)](https://circleci.com/gh/foldingbeauty/wunder-wander/tree/master)

## Status

Work in Progress | Proof of Concept

## Why Wunder-Wander Gitops?

TBD

## How to use

- Deploy the Wunder-Wander Gitops controller and CRD:


`$ kubectl apply -f https://raw.githubusercontent.com/foldingbeauty/wunder-wander/0.1.1/deployment/deployment.yaml`


- Check if everything is ready to go:

```
$ kubectl get all -n wunderwander-gitops

NAME                                              READY   STATUS    RESTARTS   AGE
pod/gitops-operator-controller-64757768b5-g82jr   1/1     Running   0          22s
pod/gitops-operator-ui-6b978c66bf-5jkcg           1/1     Running   1          22s

NAME                                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/gitops-operator-controller   1         1         1            1           24s
deployment.apps/gitops-operator-ui           1         1         1            1           24s

NAME                                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/gitops-operator-controller-64757768b5   1         1         1       24s
replicaset.apps/gitops-operator-ui-6b978c66bf           1         1         1       24s

```

- Get the SSH Public key and add the key to your Git repository

`$ kubectl get  secret/ssh-keys -n wunderwander-gitops -o jsonpath="{.data.public_key}"| base64 --decode ; echo`

```
ssh-rsa ... ==
```

- Create a Gitops Resource with your Git repository


*example-gitops-crd.yaml*
``` 
apiVersion: "io.wunderwander/v1"
kind: GitOp
metadata:
  # the name of the CRD + branch name is the name of the namespace
  name: test-app
  namespace: wunderwander-gitops
spec:
  repo: git@github.com:foldingbeauty/wunderwander-test-app.git
  branch: master
```

`$ kubectl apply -f example-gitops-crd.yaml`

When a GitOps resource is deployed, the Wunder-Wander controller will checkout the Git repository and start deploying the contents. 

- Check the deployment

```
$ kubectl get all -n wunderwander-gitops

NAME                                              READY   STATUS    RESTARTS   AGE
pod/gitops-operator-controller-64757768b5-g82jr   1/1     Running   0          6m24s
pod/gitops-operator-ui-6b978c66bf-5jkcg           1/1     Running   1          6m24s
pod/test-app-c67cd5bfc-wqmq8                      1/1     Running   0          50s

NAME                                         DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/gitops-operator-controller   1         1         1            1           6m25s
deployment.apps/gitops-operator-ui           1         1         1            1           6m25s
deployment.apps/test-app                     1         1         1            1           50s

NAME                                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/gitops-operator-controller-64757768b5   1         1         1       6m25s
replicaset.apps/gitops-operator-ui-6b978c66bf           1         1         1       6m25s
replicaset.apps/test-app-c67cd5bfc                      1         1         1       50s
```

- Check if you the GitOps worker can connect to your Git repository

```
$ kubectl logs deploy/test-app -n wunderwander-gitops

I, [2019-02-25T20:13:20.943442 #1]  INFO -- : ---
I, [2019-02-25T20:13:20.943755 #1]  INFO -- : WunderWander GitOps Worker v0.1.0
I, [2019-02-25T20:13:20.943846 #1]  INFO -- : Lets get to work!
I, [2019-02-25T20:13:20.943921 #1]  INFO -- : ---
I, [2019-02-25T20:13:20.944243 #1]  INFO -- : Create deployment namespace test
I, [2019-02-25T20:13:21.006650 #1]  INFO -- : Check SSH connection to github.com
I, [2019-02-25T20:13:21.906947 #1]  INFO -- : Can connect to Git repo github.com
I, [2019-02-25T20:13:21.907545 #1]  INFO -- : Retry in 10 seconds.
.... // ADD YOUR SSH KEY TO YOUR GIT REPO!
I, [2019-02-25T20:17:22.085614 #1]  INFO -- : SSH connection to github.com OK!
I, [2019-02-25T20:17:22.086103 #1]  INFO -- : ---
I, [2019-02-25T20:17:35.523779 #1]  INFO -- : Deployment changed, update deployment with ref 764adde6d33b9bae36e4d660175441c6600bc71d
```

Wunder-Wander for the Win!

```
$ kubectl get pods -n test
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-6cbcd97dd7-rc2hh   1/1     Running   0          21m
```
