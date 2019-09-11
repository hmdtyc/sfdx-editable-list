# Editable List (Record Hunter's Add-on)

Editable List is a record list component that allows you to update multiple items at one time.

### What you can do
- Edit multiple fields of multiple records at one time
- Easily find edited items as they get highlighted
- Reset your edit as long as it's not saved
- Select picklist values based on record type if any
- Search and select a record when editing a lookup field

### Prerequisite
This component is a Record Hunter's Add-on. Make sure to [install it from AppExchange](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FR4jTUAT) in advance

## Dev, Build and Test

1. Install [Record Hunter](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FR4jTUAT) from AppExchange
2. git clone this repository and deploy by yourself

## How to use Editable List

### Setup Instruction
1. Drag and drop Editable List with Record Hunter's Search Box in Lightning App Builder
2. Change default settings to suit your needs
 - Target Object: Object to query and display
- Column Fields: Fields to query and display
- Rows: Maximum Number of records to query and display  
  Be aware that it will have performance drawbacks if you have too many items (columns × rows)
- Order:  Order is determined by adding 1 to that of the component which passes the search result to this component  
(For example, if you just use Search Box and Editable List, set 1 for Search Box and 2 for Editable List)

### Limitations
- 200 is the maximum number of rows
- Address, Formula, Combobox, Multipicklist, Location, and some other data types are not supported
- Lookup fields that reference to more than one object is not supported such as WhatId of Task object
- Input fields for Picklist and Lookup field are implemented with UI API. Supported objects for those fields complies with that of UI API. [User Interface API Developer Guide: Supported Objects](https://developer.salesforce.com/docs/atlas.en-us.uiapi.meta/uiapi/ui_api_get_started_supported_objects.htm)

## Disclaimer
This code is only a sample code and has not been fully tested. Please use this code at your own risks. This software is released under the MIT License, see LICENSE.txt.
