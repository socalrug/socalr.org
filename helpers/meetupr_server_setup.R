### Create a key

token_path <- "~/Library/Application Support/meetupr/meetup_token.rds"

meetupr::meetup_auth(
  token = NULL,
  cache = TRUE,
  use_appdir = FALSE,
  token_path = token_path
)

### Encrypt the existing token to a commitable file, meetupr_secret.rds

# sodium_key <- sodium::keygen()
# save an environment variable "MEETUPR_PWD" = sodium::bin2hex(sodium_key)

key <- cyphr::key_sodium(sodium::hex2bin(Sys.getenv("MEETUPR_PWD")))

cyphr::encrypt_file(
  token_path,
  key = key,
  dest = "meetupr_secret.rds"
)

