/*
 *
 * This script copies static files from the specified
 * folders to their respective destinations.
 */

const fs = require("fs-extra")
const path = require("path")

// The js folder is inside assets, so we need to go up to the project root
const projectRoot = path.resolve(__dirname, "../../")

// Validate project root exists
if (!fs.existsSync(projectRoot)) {
  console.error(`❌ Project root not found at ${projectRoot}`)
  process.exit(1)
}

const folderMappings = [
  {
    source: "assets/images",
    destination: "priv/static/images",
    extensions: [".jpg", ".jpeg", ".png", ".gif", ".svg", ".webp", ".ico"]
  },
  {
    source: "assets/misc",
    destination: "priv/static",
    extensions: [".ico", ".txt", ".png", ".webmanifest", ".svg"]
  }
]

for (const { source, destination, extensions } of folderMappings) {
  const absoluteSource = path.resolve(projectRoot, source)
  const absoluteDestination = path.resolve(projectRoot, destination)

  console.log(`Processing: ${source} → ${destination}`)

  try {
    fs.ensureDirSync(absoluteSource)
    fs.ensureDirSync(absoluteDestination)

    fs.copySync(
      absoluteSource,
      absoluteDestination,
      {
        overwrite: true,
        filter: (src) => {
          try {
            if (fs.lstatSync(src).isDirectory()) {
              return true
            }

            const ext = path.extname(src).toLowerCase()


            return extensions.includes(ext)
          } catch (filterErr) {
            console.warn(`- ⚠️ Warning: Could not process ${src}: ${filterErr.message}`)

            return false
          }
        }
      }
    )

    console.log("- ✅ Done!\n")
  } catch (err) {
    console.error(`❌ Error copying files from ${source} to ${destination}:`, err)
    console.error(`  Source exists: ${fs.existsSync(absoluteSource)}`)
    console.error(`  Destination parent exists: ${fs.existsSync(path.dirname(absoluteDestination))}`)
  }
}
