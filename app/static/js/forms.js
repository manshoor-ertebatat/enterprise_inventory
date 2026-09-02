document.addEventListener("DOMContentLoaded", function () {

    // تبدیل اعداد فارسی و عربی به انگلیسی
    function fixDigits(value) {

        const fa = "۰۱۲۳۴۵۶۷۸۹";
        const ar = "٠١٢٣٤٥٦٧٨٩";

        return value
            .replace(/[۰-۹]/g, d => fa.indexOf(d))
            .replace(/[٠-٩]/g, d => ar.indexOf(d));
    }

    document.querySelectorAll("input").forEach(function (el) {

        el.addEventListener("input", function () {
            this.value = fixDigits(this.value);
        });

    });

    // حرکت با Enter
    document.addEventListener("keydown", function (e) {

        if (e.key !== "Enter")
            return;

        const tag = e.target.tagName.toLowerCase();

        if (tag === "textarea")
            return;

        e.preventDefault();

        const fields = Array.from(
            document.querySelectorAll(
                "input, select, textarea, button"
            )
        ).filter(f =>
            !f.disabled &&
            f.offsetParent !== null
        );

        const index = fields.indexOf(e.target);

        if (index >= 0 && index < fields.length - 1) {

            fields[index + 1].focus();

        }

    });

});

// ================================
// Material Request Items
// ================================

document.addEventListener("DOMContentLoaded", function () {

    const addBtn = document.getElementById("add-row");

    if (!addBtn)
        return;

    addBtn.addEventListener("click", function () {

        const tbody =
            document.querySelector("#items-table tbody");

        const firstRow =
            tbody.querySelector("tr");

        const newRow =
            firstRow.cloneNode(true);

        newRow.querySelector("input").value = 1;

        newRow.querySelector("button").outerHTML = `
<button
type="button"
class="btn btn-danger remove-row">
🗑
</button>`;

        tbody.appendChild(newRow);

    });

    document.addEventListener("click", function (e) {

        if (!e.target.classList.contains("remove-row"))
            return;

        const rows =
            document.querySelectorAll("#items-table tbody tr");

        if (rows.length === 1)
            return;

        e.target.closest("tr").remove();

    });

});