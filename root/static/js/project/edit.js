const modal = new bootstrap.Modal(document.getElementById('modal'));
const modalTitleEl = document.getElementById('modalTitle');
const modalFormEl = document.getElementById('modalForm');
const modalBodyEl = document.getElementById('modalBody');
const modalConfirmEl = document.getElementById('modalConfirmElement');

const editMeal = (updateMealURL, nameValue, commentValue) => {
    const bodyHTML = `
    <div class="d-flex flex-column gap-2">
        <div>
            <label for="nameInput" class="form-label">Name</label>
            <input id="nameInput" type="text" name="name" value="${nameValue}" class="form-control">
                        
        </div>
        <div>
            <label for="commentInput" class="form-label">Comment</label>
            <input id="commentInput" type="text" name="comment" value="${commentValue}" placeholder="comment" class="form-control">
        </div>
    </div>`;
    openModal("Edit meal", updateMealURL, bodyHTML, "Update meal");
}

const createMealOnDate = (mealCreateURL, date) => {
    const bodyHTML = `
    <div class="d-flex flex-column gap-2">
        <input type="hidden" name="date" value="${date}">
        <div>
            <label for="nameInput" class="form-label">Name</label>
            <input id="nameInput" type="text" name="name" placeholder="name" required class="form-control">
        </div>
        <div>
            <label for="commentInput" class="form-label">Comment</label>
            <input id="commentInput" type="text" name="comment" placeholder="comment" class="form-control">
        </div>
    </div>`;
    openModal("Add meal on " + date, mealCreateURL, bodyHTML, "Add meal");
}

const createMeal = (mealCreateURL, date) => {
    const bodyHTML = `
    <div class="d-flex flex-column gap-2">
        <div>
            <label for="dateInput" class="form-label">Date</label>
            <input id="dateInput" type="date" name="date" placeholder="YYYY-MM-DD" required value="${date}" class="form-control">
        </div>
        <div>
            <label for="nameInput" class="form-label">Name</label>
            <input id="nameInput" type="text" name="name" placeholder="name" required class="form-control">
        </div>
        <div>
            <label for="commentInput" class="form-label">Comment</label>
            <input id="commentInput" type="text" name="comment" placeholder="comment" class="form-control">
        </div>
    </div>`;
    openModal("Add meal", mealCreateURL, bodyHTML, "Add meal");
}

const openModal = (title, formActionURL, bodyHTML, confirmText) => {
    modalTitleEl.innerHTML = title;
    modalFormEl.setAttribute('action', formActionURL);
    modalBodyEl.innerHTML = bodyHTML;
    modalConfirmEl.setAttribute('value', confirmText);
    modal.show();
}