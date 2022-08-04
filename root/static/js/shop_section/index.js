function setModal(e) {
    let url = e.currentTarget.dataset.url;
    let name = e.currentTarget.dataset.name;

    document.getElementById("update-section").action = url;
    document.getElementById("section-name").innerText = name;
    document.getElementById("ss-new-name").value = name;
    document.getElementById("updateSection").addEventListener("shown.bs.modal", () => document.getElementById("ss-new-name").focus());
}

document.querySelectorAll(".update").forEach(elem => elem.addEventListener("click", setModal));

document.getElementById("addSection").addEventListener("shown.bs.modal", () => document.getElementById("ss-name").focus());
