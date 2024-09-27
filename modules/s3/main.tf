resource "aws_s3_bucket" "my-bucket" {
  count = length(var.buckets)
  bucket = var.buckets[count.index]
}