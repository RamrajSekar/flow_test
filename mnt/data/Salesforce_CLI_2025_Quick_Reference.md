# 🧭 Salesforce CLI 2025 Quick Reference

> 🔹 Fully aligned with the latest unified `sf` CLI (v2.108+).  
> 🔹 Uses `generate`, `deploy metadata`, and `retrieve metadata` commands — no legacy `sfdx` syntax.  
> 🔹 Works for Developer, Scratch, and Partner Orgs.

---

## ⚙️ Project Setup

| Purpose | Command | Example |
|----------|----------|----------|
| Create new project | `sf project generate --name MyProject` | Creates SFDX structure |
| Authorize org | `sf org login web --alias DevOrg` | Opens browser for login |
| List authorized orgs | `sf org list` | Shows active orgs |
| Open default org | `sf org open` | Opens Salesforce UI |
| Set default org | `sf config set target-org=DevOrg` | Defines target org for deploys |

---

## 💻 Apex Commands

| Purpose | Command | Example |
|----------|----------|----------|
| Generate new class | `sf apex class generate --name MyClass --directory force-app/main/default/classes` | Creates .cls + .xml |
| Generate test class | `sf apex class generate --name MyClass_Test --template ApexUnitTest --directory force-app/main/default/classes` | Uses built-in test template |
| Run Apex code snippet | `sf apex run --file scripts/apex/TestRun.apex` | Executes Apex file |
| Execute anonymous Apex | `sf apex run --apex "System.debug('Hello');"` | Inline execution |
| Run Apex tests | `sf apex test run --classnames MyClass_Test` | Runs specific test class |
| View test results | `sf apex test report --result-format human` | Displays test summary |

---

## 🧩 Metadata: Deploy / Retrieve

| Purpose | Command | Example |
|----------|----------|----------|
| Deploy source directory | `sf deploy metadata --source-dir force-app/main/default` | Deploy all local changes |
| Deploy using manifest | `sf deploy metadata --manifest manifest/package.xml` | Targeted deploy |
| Validate deploy (no commit) | `sf deploy metadata validate --manifest manifest/package.xml` | Dry run |
| Report deploy status | `sf deploy metadata report` | Shows progress/status |
| Retrieve all metadata | `sf retrieve metadata --all` | Full org pull |
| Retrieve using manifest | `sf retrieve metadata --manifest manifest/package.xml` | Selective retrieve |
| Retrieve by metadata type | `sf retrieve metadata --metadata "ApexClass:*"` | Pulls all classes |
| List available metadata types | `sf metadata type list` | View supported types |
| View org metadata coverage | `sf metadata coverage report` | Opens Salesforce metadata coverage info |

---

## ⚡ Lightning Web Components (LWC)

| Purpose | Command | Example |
|----------|----------|----------|
| Generate LWC | `sf lightning component generate --name fgFlowDashboard --directory force-app/main/default/lwc` | Creates LWC bundle |
| Preview LWC locally | `sf lightning preview` | Starts local dev server |
| Deploy LWC | `sf deploy metadata --source-dir force-app/main/default/lwc/fgFlowDashboard` | Deploy specific LWC |

---

## 🧱 Custom Objects / Flows

| Purpose | Command | Example |
|----------|----------|----------|
| Retrieve custom objects | `sf retrieve metadata --metadata "CustomObject:*"` | Pulls all objects |
| Retrieve flows | `sf retrieve metadata --metadata "Flow:*"` | Pulls all Flows |
| Deploy custom metadata | `sf deploy metadata --metadata "CustomMetadata:*"` | Deploys configuration records |

---

## 🧮 Data & SOQL

| Purpose | Command | Example |
|----------|----------|----------|
| Query SOQL | `sf data query --query "SELECT Id, Name FROM Account LIMIT 5"` | Quick query |
| Import data (tree format) | `sf data import tree --plan data/data-plan.json` | Complex data import |
| Export data (tree format) | `sf data export tree --query "SELECT Id, Name FROM Contact"` | Structured export |

---

## 🧠 Org & Environment Management

| Purpose | Command | Example |
|----------|----------|----------|
| Create scratch org | `sf org create scratch --definition-file config/project-scratch-def.json --alias DevScratch --duration-days 7` | Creates temp org |
| Delete org | `sf org delete scratch --target-org DevScratch` | Deletes scratch org |
| Display org info | `sf org display` | Shows details for default org |
| Set default username | `sf config set target-org=DevOrg` | Persistent default |

---

## 📦 Package & AppExchange Prep

| Purpose | Command | Example |
|----------|----------|----------|
| Create package | `sf package generate --name FlowTestAutomation --path force-app` | Initializes package |
| Create package version | `sf package version generate --package FlowTestAutomation --installation-keybypass` | Builds version |
| Promote version | `sf package version promote --package FlowTestAutomation@1.0.0-1` | Prepares for listing |
| Install package | `sf package install --package FlowTestAutomation@1.0.0-1 --target-org DevOrg` | Installs version in org |

---

## 🧰 Maintenance & Plugin Management

| Purpose | Command |
|----------|----------|
| Update CLI | `sf update` |
| Update plugins | `sf plugins update` |
| List plugins | `sf plugins list` |
| Install templates plugin | `sf plugins install @salesforce/plugin-templates` |
| Repair CLI | `sf plugins repair` |

---

## ✅ Recommended CLI Versions
| Plugin | Minimum Version |
|---------|----------------|
| `@salesforce/cli` | 2.108+ |
| `@salesforce/plugin-deploy-retrieve` | 4.x+ |
| `@salesforce/plugin-templates` | 56.x+ |
| `salesforcedx` | (Optional legacy) 60.x+ |
