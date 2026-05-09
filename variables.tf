variable "location" {
  description = "Azure region"
  default     = "westus"
}

variable "ssh_public_key_path" {
  description = "Path to your public SSH key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "host_os" {
  description = "Host operating system (windows or linux)"
  default     = "windows"
}