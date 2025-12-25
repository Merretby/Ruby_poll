import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  disableSubmit(event) {
    this.submitTarget.disabled = true
    this.submitTarget.value = "Saving…"
  }
}