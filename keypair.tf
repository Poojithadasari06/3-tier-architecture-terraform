resource "aws_key_pair" "Project_key" {
  key_name   = "Project_key"
  public_key = file("C:/Users/Poojitha/OneDrive/Desktop/Project_key.pub")
}