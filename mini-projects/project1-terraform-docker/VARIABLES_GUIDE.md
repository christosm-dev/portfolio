# Terraform Variables Guide - Project 1

This guide explains how to use variables in your Terraform configuration.

---

## 📚 What Are Variables?

Variables make your Terraform configuration **flexible** and **reusable**. Instead of hardcoding values like `8080` or `"nginx:latest"`, you define variables that can be changed without modifying your main configuration files.

---

## 📁 Files Added

- **variables.tf** - Variable declarations
- **terraform.tfvars.example** - Example of how to set custom values

---

## 🔧 How Variables Work

### 1. Variable Declaration (variables.tf)

Each variable has:
- **Name** - How you reference it in code
- **Type** - string, number, bool, list, map, etc.
- **Description** - What the variable is for
- **Default** - Value used if not overridden
- **Validation** (optional) - Rules the value must follow

Example:
```hcl
variable "external_port" {
  description = "External port to expose the container on"
  type        = number
  default     = 8080
  
  validation {
    condition     = var.external_port > 1024 && var.external_port < 65535
    error_message = "External port must be between 1024 and 65535."
  }
}
```

### 2. Variable Reference (main.tf)

Use variables with the `var.` prefix:

```hcl
resource "docker_container" "nginx" {
  name = var.container_name
  
  ports {
    external = var.external_port
  }
}
```

### 3. Variable Interpolation (outputs.tf)

You can embed variables in strings using `${}`:

```hcl
output "access_url" {
  value = "http://localhost:${var.external_port}"
}
```

---

## 🎯 Ways to Set Variable Values

Terraform looks for variable values in this order (later sources override earlier ones):

### 1. Default Values (in variables.tf)
```hcl
variable "container_name" {
  default = "terraform-nginx"
}
```

### 2. Environment Variables
```bash
export TF_VAR_container_name="my-nginx"
export TF_VAR_external_port=9090
terraform apply
```

### 3. terraform.tfvars File
Create a file named `terraform.tfvars`:
```hcl
container_name = "production-nginx"
external_port  = 9090
image_name     = "nginx:1.25"
```

Then run:
```bash
terraform apply
```

### 4. Custom .tfvars File
```bash
terraform apply -var-file="production.tfvars"
```

### 5. Command Line
```bash
terraform apply -var="external_port=9090" -var="container_name=test-nginx"
```

### 6. Interactive Prompt
If a variable has no default and isn't set, Terraform will ask:
```bash
var.container_name
  Name of the Docker container

  Enter a value: 
```

---

## 🧪 Experiments to Try

### Experiment 1: Change the Port

**Method A - Command Line:**
```bash
terraform apply -var="external_port=9090"
```

**Method B - tfvars File:**
1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Edit the `external_port` value
3. Run `terraform apply`

**What to observe:**
- Terraform detects the change
- Shows the container will be recreated
- New URL will be `http://localhost:9090`

### Experiment 2: Use a Different Image

Try using Apache instead of nginx:
```bash
terraform apply -var="image_name=httpd:latest"
```

**What happens:**
- Terraform pulls the Apache image
- Recreates the container with Apache
- Still accessible on the same port

### Experiment 3: Run Multiple Environments

Create different `.tfvars` files:

**dev.tfvars:**
```hcl
container_name = "dev-nginx"
external_port  = 8080
```

**staging.tfvars:**
```hcl
container_name = "staging-nginx"
external_port  = 8081
```

**prod.tfvars:**
```hcl
container_name = "prod-nginx"
external_port  = 8082
image_name     = "nginx:1.25"  # Use specific version for prod
```

Deploy each:
```bash
terraform apply -var-file="dev.tfvars"
terraform apply -var-file="staging.tfvars"
terraform apply -var-file="prod.tfvars"
```

Now you have 3 containers running simultaneously!

### Experiment 4: Test Variable Validation

Try an invalid port:
```bash
terraform apply -var="external_port=80"
```

**What happens:**
- Terraform validation catches the error
- Shows your custom error message
- Doesn't proceed with apply

---

## 🎓 Variable Types Explained

### String
```hcl
variable "container_name" {
  type    = string
  default = "my-container"
}
```

### Number
```hcl
variable "external_port" {
  type    = number
  default = 8080
}
```

### Bool
```hcl
variable "keep_image_locally" {
  type    = bool
  default = false
}
```

### List
```hcl
variable "tags" {
  type    = list(string)
  default = ["web", "nginx", "production"]
}
```

Usage: `var.tags[0]` or `var.tags`

### Map
```hcl
variable "port_mapping" {
  type = map(number)
  default = {
    http  = 80
    https = 443
  }
}
```

Usage: `var.port_mapping["http"]`

### Object
```hcl
variable "container_config" {
  type = object({
    name  = string
    port  = number
    image = string
  })
  default = {
    name  = "nginx"
    port  = 8080
    image = "nginx:latest"
  }
}
```

Usage: `var.container_config.name`

---

## ✅ Best Practices

1. **Always provide descriptions** - Helps others understand what each variable does

2. **Use meaningful defaults** - For common use cases

3. **Add validation** - Catch errors early
   ```hcl
   validation {
     condition     = var.external_port > 1024
     error_message = "Port must be above 1024."
   }
   ```

4. **Don't commit secrets** - Use environment variables or external secret management
   ```bash
   # .gitignore already includes
   *.tfvars
   ```

5. **Use type constraints** - Prevent invalid values
   ```hcl
   type = number  # Can't accidentally pass a string
   ```

6. **Group related variables** - Keep variables.tf organized
   ```hcl
   # Container Configuration
   variable "container_name" { ... }
   
   # Network Configuration
   variable "external_port" { ... }
   ```

---

## 🔍 Common Patterns

### Optional Variables (No Default)
```hcl
variable "admin_password" {
  description = "Administrator password (required)"
  type        = string
  sensitive   = true
  # No default - must be provided
}
```

### Sensitive Variables
```hcl
variable "api_key" {
  type      = string
  sensitive = true  # Won't show in logs
}
```

### Complex Validation
```hcl
variable "environment" {
  type = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

---

## 🐛 Troubleshooting

### "No value for required variable"
**Problem:** Variable has no default and wasn't provided
**Solution:** Set via command line, tfvars file, or add a default

### "Invalid value for variable"
**Problem:** Value doesn't match validation rules
**Solution:** Check validation block conditions

### "Variable not found"
**Problem:** Typo in variable name
**Solution:** Variables are case-sensitive - check spelling

---

## 📝 Summary

You now understand:
- ✅ How to declare variables with types and defaults
- ✅ How to reference variables using `var.name`
- ✅ Multiple ways to set variable values
- ✅ Variable validation and constraints
- ✅ Best practices for organizing variables

---

## ➡️ Next Steps

1. Try all the experiments above
2. Create your own custom .tfvars files
3. Experiment with list and map variable types
4. Add a new variable (e.g., `restart_policy`)
5. Move to **Project 2** once comfortable with variables

---

**Variables are fundamental to writing reusable Terraform code!**
