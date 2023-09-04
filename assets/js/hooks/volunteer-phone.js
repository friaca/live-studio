import { AsYouType } from "../../vendor/libphonenumber-js.min"

const VolunteerPhone = {
  mounted() {
    this.el.addEventListener("input", e => {
      let phone = new AsYouType("US").input(e.target.value)
      this.el.value = phone;
    });
  },
}

export default VolunteerPhone;