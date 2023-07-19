let addModal = bootstrap.Modal.getOrCreateInstance(
    document.getElementById("addCol")
);

let editModal = bootstrap.Modal.getOrCreateInstance(
    document.getElementById("editCol")
);

let table = document.getElementById("overview");

let editCol = null;

const openEdit = (e) => {
    document.getElementById("col-edit-name").value = e.target.innerText;
    editCol = e.target;
    editModal.show();
};

const addCol = (e) => {
    e.preventDefault();
    let name = document.getElementById("col-name").value;
    let head = table.querySelector("th:last-child");
    let btn = document.createElement("button");
    btn.innerText = name;
    btn.className = "btn btn-outline-dark";
    btn.title = "Edit column";
    btn.onclick = openEdit;
    let th = document.createElement("th");
    th.className = "extra-col";
    th.append(btn);
    head.parentElement.insertBefore(th, head);
    addModal.hide();
    for (let row of table.querySelectorAll("tbody tr")) {
        let tmp = document.createElement("td");
        tmp.innerHTML = "&nbsp;";
        row.append(tmp);
    }
};

const saveCol = (e) => {
    e.preventDefault();
    editModal.hide();
    editCol.innerText = document.getElementById("col-edit-name").value;
};

const deleteCol = () => {
    editCol.parentElement.remove();
    editModal.hide();
    for (let row of table.querySelectorAll("tbody tr")) {
        row.querySelector("td:last-child").remove();
    }
};

document.getElementById("addColForm").addEventListener("submit", addCol);
document.getElementById("delColBtn").addEventListener("click", deleteCol);
document.getElementById("editColForm").addEventListener("submit", saveCol);
document.getElementById("addCol").addEventListener("shown.bs.modal", () => {
    document.getElementById("col-name").focus();
});
document.getElementById("editCol").addEventListener("shown.bs.modal", () => {
    document.getElementById("col-edit-name").focus();
});
document.getElementById("addCol").addEventListener("hidden.bs.modal", () => {
    document.getElementById("col-name").value = "";
});
document.getElementById("editCol").addEventListener("hidden.bs.modal", () => {
    document.getElementById("col-edit-name").value = "";
    editCol = null;
});

let btns = [];

window.addEventListener("beforeprint", () => {
    for (let btn of document.querySelectorAll(".extra-col button")) {
        btns.push(btn);
        btn.parentElement.innerText = btn.innerText;
    }
});

window.addEventListener("afterprint", () => {
    for (let cell of document.querySelectorAll(".extra-col")) {
        cell.innerHTML = "";
        cell.append(btns.shift());
    }
});
