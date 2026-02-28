---
layout: default
title: API
parent: Advanced Topics
nav_order: 1
---

# Target Scheduler API

{: .note }
This is a preliminary release of a read-only API to pull data from Target Scheduler.  The API will _almost certainly change rapidly_ based on user suggestions and issues.  When breaking changes are added, the version in the API path will increment.

{: .warning }
API communications are not protected in any way - either by encryption or authentication.  If this is a concern, don't use it.

The initial release of the API was contributed by NINA Discord user @Reluthan.

## Enabling the API

The API is disabled by default.  To enable, navigate to the [profile preferences](../target-management/profiles.html) for your particular profile and scroll to the bottom of the settings to _API Preferences_:
* Enable API: set to ON to start the API server.  If this is left ON, the server is automatically started when NINA starts.
* API Port: set the listen port for the API; change if you have a port conflict
* Enable Formatted Output: pretty-print the JSON responses for readability

## API Access

If the API is active, requests must use the following syntax:

```
http://localhost:{port}/ts/v0/{request}
```

where _{port}_ is the API port and _{request}_ is the particular request (detailed below).  Note that the version identifier will increment when breaking changes are released.

## Requests

When a request specifies an {id}, it will always be a GUID e.g. "c0e1645f-4d4c-4cff-b6f8-c66a58be9cd4" to specify a unique TS entity.  The GUID values are always available via other API calls.

### /version
Return the active version of Target Scheduler.  This is a simple string response, e.g. "5.9.0.0".

### /profiles
Return an array of the current NINA profiles.  The active NINA profile will have the 'Active' property set to true.  For example:

```
http://localhost:8188/ts/v0/profiles
```

returns:

```
[
  {
    "Id": "c0e1645f-4d4c-4cff-b6f8-c66a58be9cd4",
    "Name": "Profile 1",
    "Active": true
  },
  {
    "Id": "c86232f4-4952-41c6-b83f-69aa749e401f",
    "Name": "Profile 2",
    "Active": false
  },
  {
    "Id": "53d28ce2-f175-40d9-b765-3ab410efb1de",
    "Name": "Profile 3",
    "Active": false
  }
]
```


### /profiles/{id}/projects
Return an array of projects for the specified profile. For example:

```
http://localhost:8188/ts/v0/profiles/c0e1645f-4d4c-4cff-b6f8-c66a58be9cd4/projects
```

returns:

```
[
  {
    "Id": "d900ba4a-5f70-4eb1-bd30-cd4c9b45d1c4",
    "ProfileId": "c0e1645f-4d4c-4cff-b6f8-c66a58be9cd4",
    "Name": "P1",
    "State": "Active",
    "Priority": 1,
    "Description": null,
    "CreateDate": "2026-02-26T06:17:59-05:00",
    "ActiveDate": "1969-12-31T19:00:00-05:00",
    "InactiveDate": "1969-12-31T19:00:00-05:00",
    "MinimumTime": 30,
    "UseCustomHorizon": false,
    "HorizonOffset": 0,
    "MeridianWindow": 0,
    "FilterSwitchFrequency": 0,
    "DitherEvery": 0,
    "EnableGrader": true,
    "Mosaic": false,
    "FlatsHandling": 0,
    "MinimumAltitude": 0,
    "MaximumAltitude": 0,
    "SmartExposureOrder": false
  },
  {
    "Id": "da436a23-a700-402b-aea5-db438f7ce565",
    "ProfileId": "c0e1645f-4d4c-4cff-b6f8-c66a58be9cd4",
    "Name": "P2",
    "State": "Draft",
    "Priority": 1,
    "Description": null,
    "CreateDate": "2026-02-26T13:57:47-05:00",
    "ActiveDate": "1969-12-31T19:00:00-05:00",
    "InactiveDate": "1969-12-31T19:00:00-05:00",
    "MinimumTime": 30,
    "UseCustomHorizon": false,
    "HorizonOffset": 0,
    "MeridianWindow": 0,
    "FilterSwitchFrequency": 0,
    "DitherEvery": 0,
    "EnableGrader": true,
    "Mosaic": false,
    "FlatsHandling": 0,
    "MinimumAltitude": 0,
    "MaximumAltitude": 0,
    "SmartExposureOrder": false
  }
]
```


### /projects/{id}/targets
Return an array of targets for the specified project.  For example:

```
http://localhost:8188/ts/v0/projects/d900ba4a-5f70-4eb1-bd30-cd4c9b45d1c4/targets
```

returns:

```
[
  {
    "Id": "134973bf-f949-462d-9c4b-8baad53d75a8",
    "ProjectId": "d900ba4a-5f70-4eb1-bd30-cd4c9b45d1c4",
    "Name": "M 31",
    "Active": true,
    "RA": 0.7123138886666667,
    "Dec": 41.26875,
    "Rotation": 0,
    "Epoch": "J2000",
    "ROI": 100,
    "ExposurePlan": [
      {
        "TemplateName": "Lum",
        "Exposure": 60,
        "FilterName": "Lum",
        "Desired": 1,
        "Acquired": 0,
        "Accepted": 0,
        "Ungraded": 0
      },
      {
        "TemplateName": "Red",
        "Exposure": 60,
        "FilterName": "Red",
        "Desired": 1,
        "Acquired": 0,
        "Accepted": 0,
        "Ungraded": 0
      },
      {
        "TemplateName": "Green",
        "Exposure": 60,
        "FilterName": "Green",
        "Desired": 1,
        "Acquired": 0,
        "Accepted": 0,
        "Ungraded": 0
      },
      {
        "TemplateName": "Blue",
        "Exposure": 60,
        "FilterName": "Blue",
        "Desired": 1,
        "Acquired": 0,
        "Accepted": 0,
        "Ungraded": 0
      }
    ]
  }
]
```


### /targets/{id}/statistics
Return various statistics on exposures taken for a target.  For example:

```
http://localhost:8188/ts/v0/targets/134973bf-f949-462d-9c4b-8baad53d75a8/statistics
```

returns:

```
[
  {
    "Exposure": 60,
    "FilterName": "Lum",
    "HFRMean": 0,
    "HFRStdDev": 0,
    "HFRBelowAutoAcceptLevel": -1,
    "FWHMMean": 0,
    "FWHMStdDev": 0,
    "FWHMBelowAutoAcceptLevel": -1,
    "EccentricityMean": 0,
    "EccentricityStdDev": 0,
    "EccentricityBelowAutoAcceptLevel": -1
  },
  {
    "Exposure": 60,
    "FilterName": "Red",
    "HFRMean": 0,
    "HFRStdDev": 0,
    "HFRBelowAutoAcceptLevel": -1,
    "FWHMMean": 0,
    "FWHMStdDev": 0,
    "FWHMBelowAutoAcceptLevel": -1,
    "EccentricityMean": 0,
    "EccentricityStdDev": 0,
    "EccentricityBelowAutoAcceptLevel": -1
  },
  {
    "Exposure": 60,
    "FilterName": "Green",
    "HFRMean": 0,
    "HFRStdDev": 0,
    "HFRBelowAutoAcceptLevel": -1,
    "FWHMMean": 0,
    "FWHMStdDev": 0,
    "FWHMBelowAutoAcceptLevel": -1,
    "EccentricityMean": 0,
    "EccentricityStdDev": 0,
    "EccentricityBelowAutoAcceptLevel": -1
  },
  {
    "Exposure": 60,
    "FilterName": "Blue",
    "HFRMean": 0,
    "HFRStdDev": 0,
    "HFRBelowAutoAcceptLevel": -1,
    "FWHMMean": 0,
    "FWHMStdDev": 0,
    "FWHMBelowAutoAcceptLevel": -1,
    "EccentricityMean": 0,
    "EccentricityStdDev": 0,
    "EccentricityBelowAutoAcceptLevel": -1
  }
]
```


### /profiles/{id}/preview
Run a scheduler preview for the specified profile using the current date.  For example:

```
http://localhost:8188/ts/v0/profiles/c0e1645f-4d4c-4cff-b6f8-c66a58be9cd4/preview
```

returns:

```
[
  {
    "Id": null,
    "Name": null,
    "WaitPeriod": true,
    "StartTime": "2026-02-27T13:00:00-05:00",
    "EndTime": "2026-02-27T19:38:15.443681-05:00",
    "ExposurePlan": []
  },
  {
    "Id": "134973bf-f949-462d-9c4b-8baad53d75a8",
    "Name": "M 31",
    "WaitPeriod": false,
    "StartTime": "2026-02-27T19:38:15.443681-05:00",
    "EndTime": "2026-02-27T19:42:15.443681-05:00",
    "ExposurePlan": [
      {
        "FilterName": "Lum",
        "Exposure": 60,
        "Count": 1
      },
      {
        "FilterName": "Red",
        "Exposure": 60,
        "Count": 1
      },
      {
        "FilterName": "Green",
        "Exposure": 60,
        "Count": 1
      },
      {
        "FilterName": "Blue",
        "Exposure": 60,
        "Count": 1
      }
    ]
  }
]
```

