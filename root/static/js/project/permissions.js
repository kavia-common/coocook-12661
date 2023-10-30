function renderUserOrgOption(data) {
    return [
        `${data.type === "user" ? "👤" : "👥"} ${data.display_name} (${
            data.name
        })`,
        data.name,
    ];
}

const userList = Array.from(
    document.querySelectorAll(".username"),
    (elem) => elem.innerText
);
const orgList = Array.from(
    document.querySelectorAll(".organization"),
    (elem) => elem.innerText
);

function filterUserOrg(data) {
    return data
        .filter((elem) => !userList.includes(elem.name))
        .filter((elem) => !orgList.includes(elem.name))
        .sort((a, b) => a.display_name > b.display_name);
}
