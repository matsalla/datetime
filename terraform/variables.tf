variable "notification_email" {
  description = "Enter email for alarm notifications when rate limit is exceeded"
  type        = string
  validation {
    condition     = can(regex("^.*@.*[.].*", var.notification_email))
    error_message = "Must enter a valid email address"
  }
}
