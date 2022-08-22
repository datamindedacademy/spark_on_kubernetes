import argparse

import boto3


def update_password(username, password):
    client = boto3.client("iam")
    response = client.create_login_profile(
        UserName=username, Password=password, PasswordResetRequired=False
    )
    print(response)


def delete_password(username):
    client = boto3.client("iam")
    response = client.delete_login_profile(UserName=username)
    print(response)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--profile",
        default="datafydemo",
        help="AWS profile to use to create users",
    )
    parser.add_argument("--username", required=True, help="User to create")
    parser.add_argument("--password", help="Password of user")
    parser.add_argument(
        "--delete",
        help="Delete login profile",
        action="store_true",
        default=False,
    )
    args = parser.parse_args()

    boto3.setup_default_session(profile_name=args.profile)
    if args.delete:
        delete_password(username=args.username)
    else:
        update_password(username=args.username, password=args.password)
