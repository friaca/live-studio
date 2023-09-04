import flatpickr from "../../vendor/flatpickr"

const BookingCalendar = {
  mounted() {
    this.pickr = flatpickr(this.el, {
      inline: true,
      mode: "range",
      showMonths: 2,
      onChange: (selectedDates) => {
        if (selectedDates.length !== 2) return;

        this.pushEvent("dates-picked", selectedDates);
      }
    })

    this.handleEvent("add-unavailable-dates", (dates) => {
      this.pickr.set("disable", [dates, ...this.pickr.config.disable])
    })

    this.pushEvent("unavailable-dates", {}, ({dates}, ref) => {
      this.pickr.set("disable", dates)
    })
  },

  destroyed() {
    this.pickr.destroy()
  }
}

export default BookingCalendar;