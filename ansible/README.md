# Readme instructions

## Create venv

Here we will use tool names `uv` (tool written in Rust) for managing Python packages

### Install uv

```bash
sudo apt install uv -y # For Ubuntu
sudo dnf install uv -y # For RHEL based
brew install uv # for MacOS
```

### Create venv with uv

It is better to specify current version of python when running `uv`

```bash
# Run it from the ../ansible/ directory
uv venv --python 3.14
```


### Install ansible with uv

```bash
uv pip install -r pip_requirements.txt
```

### Run ansible tools with uv

```bash
source .venv/bin/activate
ansible-playbook -i ./inventory/local-vagrant/hosts.yml ./playbooks/full-k8s-install.yml
deactivate
```
```

