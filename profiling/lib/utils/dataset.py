import torch
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
from torchvision.datasets import ImageFolder
from fastdownload import FastDownload
import tarfile

def get_loaders(
    source, batch_size, transform, eval_transform=None, root="data", split_ratio=0.1
):
    if eval_transform is None:
        eval_transform = transform

    trainset = source(
        root=root,
        train=True,
        download=True,
        transform=transform,
    )
    testset = source(
        root=root,
        train=False,
        download=True,
        transform=eval_transform,
    )

    trainset, valset = torch.utils.data.random_split(
        trainset,
        [int((1 - split_ratio) * len(trainset)), int(split_ratio * len(trainset))],
    )

    trainloader = DataLoader(trainset, batch_size=batch_size, shuffle=True)
    valloader = DataLoader(valset, batch_size=batch_size, shuffle=True)
    testloader = DataLoader(testset, batch_size=batch_size, shuffle=False)
    return trainloader, valloader, testloader


def get_cifar10_loaders(batch_size, root="data/cifar10", split_ratio=0.1):
    transform = transforms.Compose(
        [
            transforms.RandomCrop(32, padding=4),
            transforms.RandomHorizontalFlip(),
            transforms.ToTensor(),
            transforms.Normalize((0.4914, 0.4822, 0.4465), (0.247, 0.243, 0.261)),
        ]
    )
    eval_transform = transforms.Compose(
        [
            transforms.ToTensor(),
            transforms.Normalize((0.4914, 0.4822, 0.4465), (0.247, 0.243, 0.261)),
        ]
    )
    return get_loaders(
        datasets.CIFAR10,
        batch_size,
        transform,
        eval_transform=eval_transform,
        root=root,
        split_ratio=split_ratio,
    )


def get_fmnist_loaders(batch_size, root="data/fmnist", split_ratio=0.1):
    transform = transforms.Compose(
        [
            transforms.RandomRotation(degrees=20),
            transforms.RandomHorizontalFlip(),
            transforms.ToTensor(),
            transforms.Normalize((0.2860,), (0.3530,)),
        ]
    )
    eval_transform = transforms.Compose(
        [
            transforms.ToTensor(),
            transforms.Normalize((0.2860,), (0.3530,)),
        ]
    )
    return get_loaders(
        datasets.FashionMNIST,
        batch_size,
        transform,
        eval_transform,
        root=root,
        split_ratio=split_ratio,
    )


def get_mnist_loaders(batch_size, root="data/mnist", split_ratio=0.1):
    transform = transforms.Compose(
        [
            transforms.RandomRotation(degrees=15),
            transforms.RandomAffine(degrees=0, translate=(0.1, 0.1)),
            transforms.ToTensor(),
            transforms.Normalize((0.1307,), (0.3081,)),
        ]
    )
    eval_transform = transforms.Compose(
        [
            transforms.ToTensor(),
            transforms.Normalize((0.1307,), (0.3081,)),
        ]
    )
    return get_loaders(
        datasets.MNIST,
        batch_size,
        transform,
        eval_transform,
        root=root,
        split_ratio=split_ratio,
    )
def download_and_extract_imagenette(dest_root="data"):
    fd = FastDownload()
    archive_path = fd.download("https://s3.amazonaws.com/fast-ai-imageclas/imagenette2-320.tgz")
    extract_path = os.path.join(dest_root, "imagenette2-320")

    if not os.path.exists(extract_path):
        print(f"解壓縮到 {extract_path} ...")
        with tarfile.open(archive_path, "r:gz") as tar:
            tar.extractall(dest_root)
        print("解壓完成")
    else:
        print("已存在，不需解壓")

    return extract_path

def get_imagenette_loaders(batch_size, root="data", split_ratio=0.1):
    imagenette_root = download_and_extract_imagenette(root)

    transform = transforms.Compose([
        transforms.Resize(256),
        transforms.RandomCrop(224),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=(0.485, 0.456, 0.406),
            std=(0.229, 0.224, 0.225),
        ),
    ])

    eval_transform = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=(0.485, 0.456, 0.406),
            std=(0.229, 0.224, 0.225),
        ),
    ])

    full_trainset = ImageFolder(root=os.path.join(imagenette_root, "train"), transform=transform)
    testset = ImageFolder(root=os.path.join(imagenette_root, "val"), transform=eval_transform)

    total_len = len(full_trainset)
    val_len = int(split_ratio * total_len)
    train_len = total_len - val_len
    trainset, valset = random_split(full_trainset, [train_len, val_len])

    trainloader = DataLoader(trainset, batch_size=batch_size, shuffle=True)
    valloader = DataLoader(valset, batch_size=batch_size, shuffle=True)
    testloader = DataLoader(testset, batch_size=batch_size, shuffle=False)

    return trainloader, valloader, testloader

DATALOADERS = {
    "cifar10": get_cifar10_loaders,
    "fmnist": get_fmnist_loaders,
    "mnist": get_mnist_loaders,
    "imagenette": get_imagenette_loaders,
}

if __name__ == "__main__":
    datasets_to_load = ["cifar10", "fmnist", "mnist" , "imagenette"]
    for dataset in datasets_to_load:
        trainloader, valloader, testloader = DATALOADERS[dataset](batch_size=64)
        print(
            f"{dataset}: {len(trainloader.dataset)}, {len(valloader.dataset)}, {len(testloader.dataset)}, {trainloader.dataset[0][0].shape}"
        )
