# GoogleMeetUpdateBP

Theos tweak project for a rootless jailbreak package. The workflow builds on
GitHub-hosted **Ubuntu 22.04** rather than macOS ARM64 runners.

## Upload and build

1. Download and extract this ZIP.
2. Upload **all files and folders inside** the extracted `GoogleMeetUpdateBP` folder
   to the root of a new GitHub repository. Keep the `.github/workflows/build.yml`
   path intact.
3. Commit the files to the `main` branch.
4. Open the repository's **Actions** tab.
5. Select **Build GoogleMeetUpdateBP**, then press **Run workflow**.
   A push to `main` also starts the workflow automatically.
6. When the run succeeds, open it and download the
   `GoogleMeetUpdateBP-deb` artifact. The `.deb` is inside the downloaded ZIP.

## Package target

- Package: `com.zidan.googlemeetupdatebp`
- Version: `0.0.1`
- Rootless package architecture: `iphoneos-arm64`
- Build runner: Ubuntu 22.04
- Theos target minimum: iOS 14.0

## Important limitation

This is a new implementation based on the supplied screenshot, not a verified
port of LinkedinUpdateBP. The original DEB could not be inspected because its
download endpoint returned an error. The tweak looks for the exact update-heading
text and the "Update now" button in the Google Meet view hierarchy. It may need
adjustment if Google changes the screen or app bundle identifier. It does not
update Google Meet or bypass server-side/API compatibility checks.
