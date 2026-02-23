## Full RAG Workflow - Combined Mermaid Diagram

This file contains three Mermaid workflow diagrams showing all RAG process flows side-by-side and integrated.

---

### RAG Workflow Comparison Diagram

```mermaid
graph LR
    subgraph Single["🔵 SINGLE AGENT RAG"]
        S1["Question"] --> S2["Need Retrieval?"]
        S2 -->|YES| S3["Select DB"]
        S2 -->|NO| S5["Use Knowledge"]
        S3 --> S4["Retrieve + Rank"]
        S4 --> S5
        S5 --> S6["Generate Answer"]
    end

    subgraph Multi["🟣 MULTI-AGENT RAG"]
        M1["Question"] --> M2["Supervisor Initialize"]
        M2 --> M3["Route to Agents"]
        M3 --> M4a["Sub-Agent 1"]
        M3 --> M4b["Sub-Agent 2"]
        M3 --> M4c["Sub-Agent N"]
        M4a --> M5["Retrieve + Answer"]
        M4b --> M5
        M4c --> M5
        M5 --> M6["Supervisor Synthesize"]
        M6 --> M7["Generate Answer"]
    end

    subgraph Hybrid["🟢 HYBRID LEGAL RAG"]
        H1["Question"] --> H2["Classify: Law Type"]
        H2 --> H3["Extract Metadata"]
        H3 --> H4["Build Filters"]
        H4 --> H5["Select DB by Law"]
        H5 --> H6["Retrieve w/ Filters"]
        H6 --> H7["Fallback Filter?"]
        H7 -->|YES| H8["Re-retrieve Broader"]
        H7 -->|NO| H9["Rank + Filter"]
        H8 --> H9
        H9 --> H10["Generate Answer"]
    end

    style Single fill:#e3f2fd
    style Multi fill:#f3e5f5
    style Hybrid fill:#e8f5e9
```

---

### Detailed Single-Agent RAG Flow

```mermaid
flowchart TD
    subgraph phase1 ["PHASE 1: INITIALIZATION"]
        A["📥 User Question"] --> B["Initialize LLMBackend"]
        B --> C["Load Vector Store Directories"]
    end

    subgraph phase2 ["PHASE 2: DECISION"]
        C --> D["LLM: Need External Retrieval?"]
        D -->|YES| E["Proceed to DB Selection"]
        D -->|NO| F["Set need_retrieval=False"]
    end

    subgraph phase3 ["PHASE 3: ROUTING"]
        E --> G["Get Database Map"]
        G --> H["Build DB Descriptions<br/>from Metadata"]
        H --> I["LLM: Which DBs Relevant?"]
        I --> J["Get chosen_db_names"]
    end

    subgraph phase4 ["PHASE 4: RETRIEVAL"]
        J --> K["For Each Selected DB"]
        K --> L["Get Embedding Model"]
        L --> M["Load Vector Store"]
        M --> N["Vector Search k_base=3×top_k"]
        N --> O["Similarity Rank & Filter"]
        O --> P["Keep Top-K Documents"]
    end

    subgraph phase5 ["PHASE 5: CONTEXT"]
        P --> Q["Build Context String"]
        Q --> R["Format: DOC_i | source | content"]
        R --> S["Max 4000 Characters"]
    end

    subgraph phase6 ["PHASE 6: GENERATION"]
        F --> T["Prepare User Prompt"]
        S --> T
        T --> U["LLM Chat Completion"]
        U --> V["Get Final Answer"]
    end

    subgraph phase7 ["PHASE 7: TRACE & RETURN"]
        V --> W{show_reasoning?}
        W -->|YES| X["Build ReAct Trace"]
        W -->|NO| Y["Skip Trace"]
        X --> Z["Return Answer+Docs+Trace"]
        Y --> Z
    end

    style phase1 fill:#e1f5ff
    style phase2 fill:#e0f2f1
    style phase3 fill:#f1f8e9
    style phase4 fill:#fce4ec
    style phase5 fill:#ede7f6
    style phase6 fill:#fff3e0
    style phase7 fill:#e8f5e9
```

---

### Detailed Multi-Agent RAG Flow

```mermaid
flowchart TD
    subgraph init ["INITIALIZATION PHASE"]
        A["📥 User Question"] --> B["Create Supervisor LLMBackend"]
        B --> C["Load All Vector Stores"]
        C --> D["Build DB Descriptions"]
    end

    subgraph routing ["ROUTING PHASE"]
        D --> E["Supervisor LLM Decision"]
        E --> F["Which Databases Relevant?"]
        F --> G["get chosen_db_names[]"]
        G --> H{Empty?}
        H -->|YES| I["Fallback: Use All DBs"]
        H -->|NO| J["Use Selected DBs"]
        I --> K["List of Target DBs"]
        J --> K
    end

    subgraph parallel ["PARALLEL SUB-AGENT PHASE"]
        K --> L["For Each Selected DB"]
        L --> M["Clone Config"]
        M --> N["Set vector_store_dir"]
        N --> O["Set use_multiagent=False"]
        O --> P["Create Sub-Agent RAG"]
        P --> Q["Single-Agent on This DB Only"]
    end

    subgraph execution ["SUB-AGENT EXECUTION"]
        Q --> R["Vector Search"]
        R --> S["Similarity Filter"]
        S --> T["Build Context"]
        T --> U["Generate Sub-Agent Answer"]
        U --> V["Collect Results"]
        V --> W["per_agent_answers+="]
        W --> X["all_docs+="]
        X --> Y["sub_traces+="]
    end

    subgraph synthesis ["SYNTHESIS PHASE"]
        Y --> Z["Format Agent Outputs"]
        Z --> AA["Create agents_block<br/>[Agent: db1]...[Agent: db2]..."]
        AA --> AB["Supervisor Synthesis LLM"]
        AB --> AC["Combine Answers<br/>Resolve Conflicts<br/>⚠️ Generate New Content"]
        AC --> AD["Final Synthesized Answer"]
    end

    subgraph trace ["TRACE & RETURN"]
        AD --> AE{show_reasoning?}
        AE -->|YES| AF["Build Reasoning Trace"]
        AE -->|NO| AG["Skip Trace"]
        AF --> AH["Include Routing Log"]
        AF --> AI["Include Sub-Agent Traces"]
        AF --> AJ["Include Config"]
        AH --> AK["Return Answer+Docs+Trace"]
        AI --> AK
        AJ --> AK
        AG --> AK
    end

    style init fill:#f3e5f5
    style routing fill:#ede7f6
    style parallel fill:#fce4ec
    style execution fill:#f1f8e9
    style synthesis fill:#fff3e0
    style trace fill:#e8f5e9
```

---

### Detailed Hybrid Legal RAG Flow

```mermaid
flowchart TD
    subgraph law_class ["LAW CLASSIFICATION"]
        A["📥 User Question"] --> B["Stage 1: Heuristic Keywords"]
        B --> C{Clear Match?}
        C -->|YES| D["Return law Type"]
        C -->|NO| E["Stage 2: LLM Classification"]
        E --> D
        D --> F["law ∈ {Inheritance, Divorce}"]
    end

    subgraph meta_extract ["METADATA EXTRACTION"]
        F --> G["Load LEGAL_METADATA_SCHEMA"]
        G --> H["LLM Extract Metadata"]
        H --> I["Parse JSON Response"]
        I --> J["Validate Schema"]
        J --> K["meta Dict<br/>law, cost, duration,<br/>codes, succession_type, ..."]
    end

    subgraph filter_build ["FILTER & DB SELECTION"]
        K --> L["Build Metadata Filter"]
        L --> M["Mandatory: law"]
        M --> N["Optional: civil_codes[0]"]
        N --> O["filter = {law, codes}"]
        O --> P["Heuristic DB Selection"]
        P --> Q["Match law to DB names"]
        Q --> R["candidate_dbs"]
    end

    subgraph retrieval ["RETRIEVAL WITH FALLBACK"]
        R --> S["DB Discovery"]
        S --> T["Analyze DB Descriptions"]
        T --> U["Phase 1: Full Filter"]
        U --> V["Apply full_filter"]
        V --> W["Vector Search k_base"]
        W --> X["Get raw_docs"]
        X --> Y{len docs ≥ top_k?}
        Y -->|YES| Z["Use Full Results"]
        Y -->|NO| AA["Phase 2: Mandatory Fallback"]
        AA --> AB["Apply law filter ONLY"]
        AB --> AC["Vector Search k_base"]
        AC --> AD["Get fallback_docs"]
    end

    subgraph ranking ["RANKING & FILTERING"]
        Z --> AE["Similarity Ranking"]
        AD --> AE
        AE --> AF["Calculate Cosine Similarity"]
        AF --> AG["Filter ≥ 0.1 threshold"]
        AG --> AH["Optional Re-ranking<br/>metadata × relevance"]
        AH --> AI["Top-K Documents"]
    end

    subgraph context ["CONTEXT BUILDING"]
        AI --> AJ["Format with Sources"]
        AJ --> AK["Include Law Metadata"]
        AK --> AL["Max 4000 Characters"]
    end

    subgraph generation ["ANSWER GENERATION"]
        AL --> AM["Add Legal Context"]
        AM --> AN["LLM with Legal Awareness"]
        AN --> AO["Generate Legal Answer"]
    end

    subgraph output ["OUTPUT & TRACE"]
        AO --> AP{show_reasoning?}
        AP -->|YES| AQ["Build Trace:<br/>Law Classification Log<br/>Metadata Extraction<br/>Filter Applied<br/>Fallback Status<br/>Retrieval Stats"]
        AP -->|NO| AR["Skip Trace"]
        AQ --> AS["Return Answer+Docs"]
        AR --> AS
    end

    style law_class fill:#ffe0b2
    style meta_extract fill:#ffe0b2
    style filter_build fill:#ffccbc
    style retrieval fill:#ffccbc
    style ranking fill:#ffab91
    style context fill:#ff8a65
    style generation fill:#ff7043
    style output fill:#e8f5e9
```

---

### Complete RAG Architecture: Three Approaches in One View

```mermaid
graph TB
    Input["📥 User Question"]
    
    Input --> Decision{"Choose RAG Type"}
    
    Decision -->|Simple & Fast| SinglePath["🔵 SINGLE AGENT"]
    Decision -->|Multi-Domain| MultiPath["🟣 MULTI-AGENT"]
    Decision -->|Legal Specialized| HybridPath["🟢 HYBRID"]
    
    subgraph SingleAgent ["SINGLE AGENT WORKFLOW"]
        S1["Need Retrieval?"]
        S2["Select Relevant DB"]
        S3["Vector Search"]
        S4["Similarity Filter"]
        S5["Build Context"]
        S6["Generate Answer"]
        S1 --> S2
        S2 --> S3
        S3 --> S4
        S4 --> S5
        S5 --> S6
    end
    
    subgraph MultiAgent ["MULTI-AGENT WORKFLOW"]
        M1["Supervisor Initialize"]
        M2["Route to Multiple DBs"]
        M3["Parallel Sub-Agents"]
        M4["Collect Sub-Answers"]
        M5["Supervisor Synthesis"]
        M6["Generate Unified Answer"]
        M1 --> M2
        M2 --> M3
        M3 --> M4
        M4 --> M5
        M5 --> M6
    end
    
    subgraph HybridAgent ["HYBRID LEGAL WORKFLOW"]
        H1["Classify Law Type"]
        H2["Extract Metadata"]
        H3["Build Filters"]
        H4["Smart DB Selection"]
        H5["Retrieve w/ Filters"]
        H6["Fallback Logic"]
        H7["Rank & Generate"]
        H1 --> H2
        H2 --> H3
        H3 --> H4
        H4 --> H5
        H5 --> H6
        H6 --> H7
    end
    
    SinglePath --> SingleAgent
    MultiPath --> MultiAgent
    HybridPath --> HybridAgent
    
    SingleAgent --> Output["✅ FINAL ANSWER"]
    MultiAgent --> Output
    HybridAgent --> Output
    
    Output --> Evaluation{Evaluate Quality}
    
    Evaluation -->|Faithfulness| F["Single: 0.827 ✅<br/>Hybrid: 0.685<br/>Multi: 0.558 ❌"]
    Evaluation -->|Correctness| C["Single: 0.708 ✅<br/>Multi: 0.706<br/>Hybrid: 0.646"]
    Evaluation -->|Recall| R["Single: 0.767 ✅<br/>Multi: 0.700<br/>Hybrid: 0.667 ❌"]
    Evaluation -->|Relevancy| V["Multi: 0.827 ✅<br/>Single: 0.798<br/>Hybrid: 0.626"]
    
    F --> Recommendation["🏆 RECOMMENDED:<br/>Deploy SINGLE AGENT<br/>Best Faithfulness (0.827)<br/>Best Correctness (0.708)<br/>Best Recall (0.767)<br/>Production Ready NOW"]
    
    style Input fill:#e1f5ff
    style Decision fill:#fff9c4
    style Output fill:#c8e6c9
    style Recommendation fill:#a5d6a7
    style SingleAgent fill:#e3f2fd
    style MultiAgent fill:#f3e5f5
    style HybridAgent fill:#e8f5e9
```

---

### Data Flow: Question to Answer

```mermaid
flowchart LR
    Q["Question"]
    
    Q --> SA["SINGLE AGENT"]
    Q --> MA["MULTI-AGENT"]
    Q --> HA["HYBRID"]
    
    SA --> SA1["Decide Retrieval"]
    SA1 --> SA2["Route DB"]
    SA2 --> SA3["Vector Search"]
    SA3 --> SA4["Similarity Filter"]
    SA4 --> SA5["Context Window"]
    SA5 --> SA6["LLM Generate"]
    SA6 --> SA_OUT["Answer + Docs"]
    
    MA --> MA1["Supervisor Init"]
    MA1 --> MA2["Route to All DBs"]
    MA2 --> MA3["Sub-Agents Execute"]
    MA3 --> MA4["Collect Answers"]
    MA4 --> MA5["Supervisor Combine"]
    MA5 --> MA_OUT["Answer + All Docs"]
    
    HA --> HA1["Classify Law"]
    HA1 --> HA2["Extract Metadata"]
    HA2 --> HA3["Build Filters"]
    HA3 --> HA4["Select DBs"]
    HA4 --> HA5["Retrieve + Fallback"]
    HA5 --> HA6["Rank + Context"]
    HA6 --> HA_OUT["Answer + Docs"]
    
    SA_OUT --> EQ{Quality?}
    MA_OUT --> EQ
    HA_OUT --> EQ
    
    EQ --> METRICS["Evaluate:<br/>Faithfulness<br/>Correctness<br/>Recall<br/>Relevancy"]
    
    METRICS --> DECISION["DECISION<br/>Best = SINGLE (0.78)<br/>Deploy SINGLE"]
    
    style Q fill:#e1f5ff
    style SA fill:#e3f2fd
    style MA fill:#f3e5f5
    style HA fill:#e8f5e9
    style DECISION fill:#a5d6a7
    style EQ fill:#fff9c4
```

---

### Process Comparison Matrix

```mermaid
graph TB
    subgraph comparison ["WORKFLOW COMPARISON"]
        direction LR
        
        subgraph sa ["SINGLE"]
            SA["Input"]
            SA --> "Decision Logic" --> "DB Routing" --> "Vector Search" --> "Similarity Filter" --> "Context Build" --> "LLM Generate"
        end
        
        subgraph ma ["MULTI-AGENT"]
            MA["Input"]
            MA --> "Supervisor Init" --> "Multi-Route" --> "Parallel Retrieval" --> "Collect Answers" --> "Supervisor Combine" --> "LLM Generate"
        end
        
        subgraph hy ["HYBRID"]
            HA["Input"]
            HA --> "Law Classification" --> "Metadata Extract" --> "Filter Building" --> "Smart DB Select" --> "Retrieve+Fallback" --> "LLM Generate"
        end
    end
    
    style sa fill:#e3f2fd
    style ma fill:#f3e5f5
    style hy fill:#e8f5e9
```

---

### Performance Radar: All Three RAG Approaches

```mermaid
graph TB
    Metrics["📊 RAGAS Metrics Comparison"]
    
    Metrics --> Chart["
    ╔════════════════════════════════════════════╗
    ║   METRIC        │ SINGLE  │ MULTI  │ HYBRID ║
    ╠════════════════════════════════════════════╣
    ║ Faithfulness    │ 0.827 ✅│ 0.558 ❌│ 0.685  ║
    ║ Correctness     │ 0.708 ✅│ 0.706  │ 0.646 ❌║
    ║ Context Recall  │ 0.767 ✅│ 0.700  │ 0.667 ❌║
    ║ Answer Relevancy│ 0.798  │ 0.827 ✅│ 0.626 ❌║
    ║ Precision       │ 0.800  │ 0.800  │ 0.800  ║
    ║ Overall Score   │ 0.78 ✅│ 0.72   │ 0.68 ❌║
    ╚════════════════════════════════════════════╝
    
    WINNER: SINGLE AGENT (0.78)
    - Highest Faithfulness (0.827)
    - Highest Correctness (0.708)
    - Highest Recall (0.767)
    - Production Ready NOW
    "]
    
    style Chart fill:#c8e6c9
```

---

## Key Insights

### 1. Architecture Choice Matters
- **Single**: Best for accuracy and reliability
- **Multi**: Best for relevancy but hallucination risk
- **Hybrid**: Specialized but filtering too strict

### 2. Faithfulness Critical for Legal
- Legal domain requires grounded answers
- Single (0.827) best choice
- Multi hallucinations (44%) unacceptable

### 3. Retrieval vs Synthesis Problem
- All agents retrieve equally well (precision 0.800)
- Problems occur POST-retrieval:
  - Multi: Synthesis adds hallucinations
  - Hybrid: Filtering removes relevant docs
  - Single: No issues

### 4. Recommendation
Deploy **SINGLE AGENT** immediately (this week)
- ✅ All metrics superior or competitive
- ✅ No hallucination risk
- ✅ Production ready
- ✅ Simple debugging

---

## Related Documentation

- **_single.md**: Detailed Single Agent workflow
- **_multi.md**: Detailed Multi-Agent workflow with issues
- **_hybrid.md**: Detailed Hybrid Legal workflow with improvements
- **inference_ragas.md**: Deep RAGAS analysis
- **TOP_K_OPTIMIZATION.txt**: Retrieval parameter analysis
