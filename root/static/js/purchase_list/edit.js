let tableData = [];

window.addEventListener("beforeprint", () => {
    document.querySelectorAll(".pl-editor").forEach((elem , idx) => {
        tableData[idx] = elem.innerHTML.replaceAll("\n", "").replaceAll("\t", "");
        elem.querySelector("colgroup").innerHTML = "<col><col><col style=\"width:50%\"><col style=\"width:25%\">";
        elem.querySelector("thead th:nth-child(3)").removeAttribute("colspan");
        elem.querySelectorAll("tbody tr").forEach(row => {
            const cell = document.createElement("td");
            cell.className = "small-font border-0 p-1";
            if (row.querySelector(".rounding")) {
                cell.innerHTML = row.querySelector(".rounding").innerHTML;
                row.innerHTML = "";
            } else {
                let amount = row.querySelector(".item-amount");
                let item = row.querySelector(".item");
                let comment = row.querySelector(".comment")?.innerHTML.trim();
                cell.innerHTML = `${row.querySelector(".amount").innerHTML} - ${row.querySelector(".date").innerHTML} - ${row.querySelector(".meal").innerHTML} - ${row.querySelector(".dish").innerHTML} ${comment ? comment : ""}`;
                row.innerHTML = "";
                if (amount) row.append(amount, item);
            }

            row.append(cell);
            if (row.querySelector("td").hasAttribute("rowspan")) {
                const cCell = document.createElement("td");
                cCell.rowSpan = row.querySelector("td").rowSpan;
                row.append(cCell);
            }
        });
    });
    document.querySelector("h2").classList.remove("display-3");
});

window.addEventListener("afterprint", () => {
    document.querySelectorAll(".pl-editor").forEach((elem , idx) => {
        elem.innerHTML = tableData[idx];
    });
    document.querySelector("h2").classList.add("display-3");
});
