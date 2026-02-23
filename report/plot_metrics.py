#!/usr/bin/env python3
"""
RAGAS Metrics Visualization Script
Plots comparison of Single Agent, Multi-Agent, and Hybrid RAG metrics
"""

import matplotlib.pyplot as plt
import numpy as np
import matplotlib.patches as mpatches
from matplotlib.patches import Rectangle

# Define the metrics data
metrics = {
    'Single Agent': {
        'context_precision': 0.800,
        'context_recall': 0.767,
        'faithfulness': 0.827,
        'answer_relevancy': 0.798,
        'answer_correctness': 0.708,
    },
    'Multi-Agent': {
        'context_precision': 0.800,
        'context_recall': 0.700,
        'faithfulness': 0.558,
        'answer_relevancy': 0.827,
        'answer_correctness': 0.706,
    },
    'Hybrid Legal': {
        'context_precision': 0.800,
        'context_recall': 0.667,
        'faithfulness': 0.685,
        'answer_relevancy': 0.626,
        'answer_correctness': 0.646,
    }
}

metric_names = ['Context\nPrecision', 'Context\nRecall', 'Faithfulness', 'Answer\nRelevancy', 'Answer\nCorrectness']
agents = list(metrics.keys())

# Create figure with subplots
fig = plt.figure(figsize=(16, 12))

# Color scheme
colors = {
    'Single Agent': '#1976d2',      # Blue
    'Multi-Agent': '#7b1fa2',       # Purple
    'Hybrid Legal': '#388e3c',      # Green
}

# ==================== SUBPLOT 1: Grouped Bar Chart ====================
ax1 = plt.subplot(2, 3, 1)
x = np.arange(len(metric_names))
width = 0.25

for idx, agent in enumerate(agents):
    values = [metrics[agent][k] for k in ['context_precision', 'context_recall', 'faithfulness', 'answer_relevancy', 'answer_correctness']]
    offset = (idx - 1) * width
    bars = ax1.bar(x + offset, values, width, label=agent, color=colors[agent], alpha=0.8, edgecolor='black', linewidth=1.5)
    
    # Add value labels on bars
    for bar in bars:
        height = bar.get_height()
        ax1.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.3f}',
                ha='center', va='bottom', fontsize=8, fontweight='bold')

ax1.set_xlabel('Metrics', fontsize=11, fontweight='bold')
ax1.set_ylabel('Score', fontsize=11, fontweight='bold')
ax1.set_title('RAGAS Metrics Comparison - Grouped Bar Chart', fontsize=12, fontweight='bold')
ax1.set_xticks(x)
ax1.set_xticklabels(metric_names, fontsize=10)
ax1.legend(loc='upper left', fontsize=9)
ax1.set_ylim([0, 1.0])
ax1.grid(axis='y', alpha=0.3, linestyle='--')

# ==================== SUBPLOT 2: Line Chart ====================
ax2 = plt.subplot(2, 3, 2)
for agent in agents:
    values = [metrics[agent][k] for k in ['context_precision', 'context_recall', 'faithfulness', 'answer_relevancy', 'answer_correctness']]
    ax2.plot(x, values, marker='o', linewidth=2.5, markersize=8, label=agent, color=colors[agent])

ax2.set_xlabel('Metrics', fontsize=11, fontweight='bold')
ax2.set_ylabel('Score', fontsize=11, fontweight='bold')
ax2.set_title('RAGAS Metrics - Line Chart Comparison', fontsize=12, fontweight='bold')
ax2.set_xticks(x)
ax2.set_xticklabels(metric_names, fontsize=10)
ax2.legend(loc='best', fontsize=9)
ax2.set_ylim([0.5, 1.0])
ax2.grid(alpha=0.3, linestyle='--')

# ==================== SUBPLOT 3: Overall Score ====================
ax3 = plt.subplot(2, 3, 3)
overall_scores = {}
for agent in agents:
    overall_scores[agent] = np.mean(list(metrics[agent].values()))

bars = ax3.barh(agents, list(overall_scores.values()), color=[colors[agent] for agent in agents], 
                 edgecolor='black', linewidth=2, height=0.6)

# Add value labels
for i, (agent, score) in enumerate(overall_scores.items()):
    ax3.text(score + 0.01, i, f'{score:.3f}', va='center', fontweight='bold', fontsize=10)
    if score == max(overall_scores.values()):
        ax3.text(score + 0.01, i, f' {score:.3f} ✅', va='center', fontweight='bold', fontsize=10, color='green')

ax3.set_xlabel('Overall Score', fontsize=11, fontweight='bold')
ax3.set_title('Overall Performance Score', fontsize=12, fontweight='bold')
ax3.set_xlim([0, 1.0])
ax3.grid(axis='x', alpha=0.3, linestyle='--')

# ==================== SUBPLOT 4: Heatmap ====================
ax4 = plt.subplot(2, 3, 4)
data_matrix = np.array([
    [metrics[agent][k] for k in ['context_precision', 'context_recall', 'faithfulness', 'answer_relevancy', 'answer_correctness']]
    for agent in agents
])

im = ax4.imshow(data_matrix, cmap='RdYlGn', aspect='auto', vmin=0.5, vmax=1.0)
ax4.set_xticks(np.arange(len(metric_names)))
ax4.set_yticks(np.arange(len(agents)))
ax4.set_xticklabels(metric_names, fontsize=9)
ax4.set_yticklabels(agents, fontsize=10)
plt.setp(ax4.get_xticklabels(), rotation=45, ha="right", rotation_mode="anchor")

# Add text annotations
for i in range(len(agents)):
    for j in range(len(metric_names)):
        text = ax4.text(j, i, f'{data_matrix[i, j]:.3f}',
                       ha="center", va="center", color="black", fontsize=9, fontweight='bold')

ax4.set_title('Metrics Heatmap', fontsize=12, fontweight='bold')
cbar = plt.colorbar(im, ax=ax4, fraction=0.046, pad=0.04)
cbar.set_label('Score', fontsize=10, fontweight='bold')

# ==================== SUBPLOT 5: Radar/Spider Chart ====================
ax5 = plt.subplot(2, 3, 5, projection='polar')
angles = np.linspace(0, 2 * np.pi, len(metric_names), endpoint=False).tolist()
angles += angles[:1]  # Complete the circle

for agent in agents:
    values = [metrics[agent][k] for k in ['context_precision', 'context_recall', 'faithfulness', 'answer_relevancy', 'answer_correctness']]
    values += values[:1]  # Complete the circle
    ax5.plot(angles, values, 'o-', linewidth=2.5, label=agent, color=colors[agent], markersize=7)
    ax5.fill(angles, values, alpha=0.15, color=colors[agent])

ax5.set_xticks(angles[:-1])
ax5.set_xticklabels(metric_names, fontsize=9)
ax5.set_ylim(0, 1.0)
ax5.set_title('Radar Chart - All Metrics', fontsize=12, fontweight='bold', pad=20)
ax5.legend(loc='upper right', bbox_to_anchor=(1.3, 1.1), fontsize=9)
ax5.grid(True)

# ==================== SUBPLOT 6: Key Insights ====================
ax6 = plt.subplot(2, 3, 6)
ax6.axis('off')

insights_text = f"""
KEY INSIGHTS

🏆 WINNER: Single Agent (Score: 0.78)
├─ Best Faithfulness: 0.827 (82.7% grounded)
├─ Best Correctness: 0.708
├─ Best Recall: 0.767
└─ Status: ✅ DEPLOY NOW

⚠️  Multi-Agent (Score: 0.72)
├─ Hallucination Crisis: 0.558 faithfulness
├─ 44% answers not grounded in documents
├─ High Relevancy (0.827) masks low quality
└─ Status: ❌ DO NOT DEPLOY (needs fix)

⏸️ Hybrid Legal (Score: 0.68)
├─ Over-filtering: Loses 10% recall
├─ Lowest correctness: 0.646
├─ Legal-specific but not optimal
└─ Status: ⏸️ SHELVED (needs redesign)

CRITICAL FINDING:
• All agents retrieve equally (Precision 0.800)
• Problems occur AFTER retrieval (synthesis/filtering)
• Top-K optimization won't fix these issues
• Must fix architecture FIRST

RECOMMENDATION:
Deploy Single Agent this week
Plan Multi-Agent redesign for 1-2 months
Shelve Hybrid until soft-filtering redesign
"""

ax6.text(0.05, 0.95, insights_text, transform=ax6.transAxes, fontsize=9,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

# ==================== OVERALL TITLE ====================
fig.suptitle('RAGAS Metrics Analysis: Single vs Multi vs Hybrid RAG', 
             fontsize=16, fontweight='bold', y=0.995)

# Add timestamp and metadata
fig.text(0.5, 0.001, 'Generated: 23 Feb 2026 | Evaluation Dataset: 30 QA pairs (10 per agent) | LLM: GPT-4o-mini | Embeddings: all-MiniLM-L6-v2',
         ha='center', fontsize=8, style='italic', color='gray')

plt.tight_layout(rect=[0, 0.02, 1, 0.99])

# Save the figure
output_path = '/Users/sahayamuthukanignanadurai/Desktop/UNINA/TXTMINING/report/metrics.png'
plt.savefig(output_path, dpi=300, bbox_inches='tight', facecolor='white', edgecolor='none')
print(f"✅ Metrics visualization saved to: {output_path}")
print(f"   Resolution: 300 DPI")
print(f"   Format: PNG")

# Also display the figure (optional)
plt.show()

print("\n" + "="*70)
print("METRICS SUMMARY")
print("="*70)

print("\nSingle Agent RAG:")
for metric, value in metrics['Single Agent'].items():
    print(f"  {metric:20s}: {value:.3f}")

print("\nMulti-Agent RAG:")
for metric, value in metrics['Multi-Agent'].items():
    print(f"  {metric:20s}: {value:.3f}")

print("\nHybrid Legal RAG:")
for metric, value in metrics['Hybrid Legal'].items():
    print(f"  {metric:20s}: {value:.3f}")

print("\n" + "="*70)
print("OVERALL SCORES")
print("="*70)
for agent, score in sorted(overall_scores.items(), key=lambda x: x[1], reverse=True):
    print(f"  {agent:15s}: {score:.3f}")
