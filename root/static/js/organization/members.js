function renderUserOption(data) {
    return [`👤 ${data.display_name} (${data.name})`, data.name];
}

const userList = Array.from(
    document.querySelectorAll(".username"),
    (elem) => elem.innerText
);

function filterUser(data) {
    return data.filter((elem) => !userList.includes(elem.name));
}
