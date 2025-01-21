# RadioDJ Data Requirements

This document outlines the data structures and information we need to understand and query from the RadioDJ database for template generation and scheduling.

## Missing Information

### Category Structure
- Category definitions and hierarchies
- Subcategory relationships and rules
- Category-specific scheduling constraints  
- Category rotation patterns and rules

### Track Metadata
- Complete track metadata fields beyond basic info (id, title, artist)
- Track-category relationships
- Track-specific scheduling rules
- Track history and rotation data

### Scheduling Rules
- Defined rotation patterns
- Time slot configurations
- Category spacing rules
- Artist separation rules
- Title separation rules

### Commercial Breaks
- Break definitions
- Timing rules and constraints
- Break content requirements
- Commercial load balancing rules

### Station Elements
- Station ID specifications
- Promo requirements and rules
- Sweeper/jingle configurations
- Legal ID requirements

## Required Database Queries

We need to develop queries to:
1. Map the complete category structure
2. Extract track metadata and relationships
3. Identify existing scheduling patterns
4. Analyze break timing and content rules
5. Understand station element placement rules

## Next Steps

1. Expand db-interface.sh to include functions for:
- Category structure querying
- Track relationship mapping
- Scheduling rule extraction
- Break pattern analysis
- Station element configuration

2. Create data mapping functions to:
- Convert database records to template objects
- Validate relationships between elements
- Apply scheduling rules to templates
- Verify template integrity

3. Implement validation rules based on:
- Database constraints
- Business rules
- Technical requirements
- Legal requirements

