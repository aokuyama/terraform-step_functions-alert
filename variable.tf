variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "function_name" {
  type    = string
  default = "step_functions-alert"
}

variable "slack_hook_url" {
  type    = string
  default = "https://hooks.slack.example.com/services/xxxxxxxx"
}

variable "event_rule_name" {
  type    = string
  default = "step_functions-alert"
}

variable "target_status" {
  type    = list(string)
  default = ["FAILED"]
}
