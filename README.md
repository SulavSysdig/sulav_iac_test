# IaC Demo 

## Summary
Sysdig is introducing Git Integrations as part of its Infrastructure as Code (IaC) solution. At this time, the integrations can be used to scan incoming Pull Requests (PRs) for security violations based on predefined policies. The results of the scanning evaluation are presented in the PR itself. If passed, the user can merge; if failed the user cannot merge. Information provided in the PR also targets the problem area to assist the user in remediation.

### Shared Demo Environment Configuration 

This repo is integrated with the +kube environment (shared demo environment) in US-East (https://app.sysdigcloud.com/). 
![Screen Shot 2022-08-04 at 12 33 51 PM](https://user-images.githubusercontent.com/103782209/182914543-1b06fd62-8b77-437e-8a06-a04f75cb1df8.png)


The Git integration is configured to scan only the */charts* folder and it scans all PRs. 


![Screen Shot 2022-08-04 at 12 34 32 PM](https://user-images.githubusercontent.com/103782209/182914769-e3bc268e-08e5-4b0f-867b-bc01024c19ac.png)



## Demo Flow

### Git IaC Scanning

1. Make a small change in https://github.com/sysdiglabs/demoenv-scenarios-iac-demo/charts.  You can make a change right in the web UI by clicking on the pencil icon on the top right. 

[NOTE: The following screenshots are from the previous Github repo (https://github.com/draios/IaC_Demo). The process is exactly the same, but the repo in the screenshots is out of date.]  


![Screen Shot 2022-06-01 at 1 10 23 PM](https://user-images.githubusercontent.com/103782209/171476123-9e71a10e-186b-4cf2-b276-e22295c4e140.png)



2. Edit the file. Make a small change in the file. It really doesn't matter what it is, becaues the Pull Request won't go through.

3. Click on the radio button for "Create new branch for this commit and start a new pull request". 
4. Click on the green button "Propose changes". 
![Screen Shot 2022-06-01 at 1 13 23 PM](https://user-images.githubusercontent.com/103782209/171476363-76a3456a-808c-4621-8d6a-47ad9739c934.png)


5. In the next screen called "Open a pull request", click on the green button "Create pull request". 

 ![Screen Shot 2022-06-01 at 1 15 11 PM](https://user-images.githubusercontent.com/103782209/171474340-993e6135-0f85-46cc-871e-1edb4710e91a.png)

Note: make sure that the base branch is pointed to base:main. It should be base:main by default. 

6. Once you make the pull request, the Sysdig check will automatically run and you will see that "All checks have failed" in red. Click on "Details" to find out more. 
![Screen Shot 2022-06-01 at 1 17 43 PM](https://user-images.githubusercontent.com/103782209/171474899-d1d3e08a-e929-4964-a488-d8ffa227ba30.png)


7. This will brig you to the "Sysdig Pull Request Policy Evaluation" page, where you can see in detail, the policy violations. Click on each of the triangles (shown below) to find out more about each violation. 

![Screen Shot 2022-06-01 at 1 20 02 PM](https://user-images.githubusercontent.com/103782209/171475268-f99a1f35-e0c5-421a-a398-e7b94c1ef40c.png)

#### Resources

- Docs: https://docs.sysdig.com/en/docs/sysdig-secure/iac-security/git-iac-scanning/
- Policies: https://docs.sysdig.com/en/docs/sysdig-secure/iac-security/iac-policy-controls/

### Actionable Compliance - Remediation via Automated Pull Request 

Users can detect prioritized vulnerabilities, analyze them and remediate via a pull request. 

1. Go to the menu on the left, hover over Posture, then click on "Actionable Compliance" -> "Compliance Views". 

![Screen Shot 2022-08-04 at 12 40 27 PM](https://user-images.githubusercontent.com/103782209/182931675-3b92d270-4329-4124-878a-4cb085849da5.png)

2. Choose the "Sysdig Kubernetes" policy, click on the down arrow next to "1.2 - Immutable container filesystem", then click on "Show Results" next to "Container with writable root file system". 

![Screen Shot 2022-08-04 at 1 57 57 PM](https://user-images.githubusercontent.com/103782209/182931897-af053255-899f-4d0f-b89e-bb877e73c67a.png)


![Screen Shot 2022-08-04 at 1 59 01 PM](https://user-images.githubusercontent.com/103782209/182932045-0bb97147-e572-4d10-bd00-fd750577ba10.png)


3. Filter to find Name = "nginx-crashloop-nginx". 

![Screen Shot 2022-08-04 at 2 00 08 PM](https://user-images.githubusercontent.com/103782209/182932238-962d6875-7e9d-409e-82c7-af7c836e0e44.png)



4. Click on "Start Remediation". 

![Screen Shot 2022-08-04 at 2 00 38 PM](https://user-images.githubusercontent.com/103782209/182932367-f8cb5cc6-acb1-4148-83a4-1f6fce502726.png)

5. Choose the correct Github repo URL (already selected), then click on "Open Pull Request". 

![Screen Shot 2022-08-04 at 2 01 52 PM](https://user-images.githubusercontent.com/103782209/182933195-0ba30ad3-458f-4f0b-ad92-ef9ce570fffb.png)

6. Click on "Go to Pull Request". This should lead you to a brand new pull request in THIS repo. 

![Screen Shot 2022-08-04 at 2 02 21 PM](https://user-images.githubusercontent.com/103782209/182933423-7beb445e-29d0-4e1d-86c4-b337887e7e18.png)


#### Resources

- Docs: https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/actionable-compliance/
