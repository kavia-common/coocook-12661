function setModal(e) {
    let url = e.currentTarget.dataset.url;
    let name = e.currentTarget.dataset.name;

    document.getElementById("update-list").action = url;
    document.getElementById("list-name").innerText = name;
    document.getElementById("pl-new-name").value = name;
}

document.querySelectorAll(".update").forEach(elem => elem.addEventListener("click", setModal));