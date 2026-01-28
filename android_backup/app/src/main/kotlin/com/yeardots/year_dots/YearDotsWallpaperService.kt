package com.yeardots.year_dots

import android.app.WallpaperColors
import android.graphics.*
import android.os.Build
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import android.content.Context
import java.util.*
import kotlin.math.ceil

class YearDotsWallpaperService : WallpaperService() {
    override fun onCreateEngine(): Engine {
        return YearDotsEngine()
    }

    inner class YearDotsEngine : Engine() {
        private val handler = android.os.Handler(android.os.Looper.getMainLooper())
        private val drawRunner = Runnable { draw() }
        private var isVisible = false
        private var surfaceHolder: SurfaceHolder? = null

        override fun onVisibilityChanged(visible: Boolean) {
            isVisible = visible
            if (visible) {
                handler.post(drawRunner)
            } else {
                handler.removeCallbacks(drawRunner)
            }
        }

        override fun onSurfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
            surfaceHolder = holder
            super.onSurfaceChanged(holder, format, width, height)
            draw()
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            super.onSurfaceDestroyed(holder)
            isVisible = false
            handler.removeCallbacks(drawRunner)
        }

        override fun onOffsetsChanged(
            xOffset: Float,
            yOffset: Float,
            xOffsetStep: Float,
            yOffsetStep: Float,
            xPixelOffset: Int,
            yPixelOffset: Int
        ) {
            super.onOffsetsChanged(xOffset, yOffset, xOffsetStep, yOffsetStep, xPixelOffset, yPixelOffset)
            // Optional: Parallax
        }

        private fun draw() {
            val holder = surfaceHolder ?: return
            var canvas: Canvas? = null
            try {
                canvas = holder.lockCanvas()
                if (canvas != null) {
                    drawContent(canvas)
                }
            } finally {
                if (canvas != null) {
                    try {
                        holder.unlockCanvasAndPost(canvas)
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
            
            // Schedule next draw? Only if animating. Static dots don't animate.
            // We rely on external triggers (MethodChannel or Preference changes) to redraw.
            // However, to be safe, we can check date changes. 
            // For now, draw once on visibility/surface change.
        }

        private fun drawContent(canvas: Canvas) {
            // 1. Get Data from Shared Preferences (Flutter)
            val prefs = applicationContext.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            
            // Date Logic
            val calendar = Calendar.getInstance()
            val dayOfYear = calendar.get(Calendar.DAY_OF_YEAR)
            val year = calendar.get(Calendar.YEAR)
            val totalDays = if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) 366 else 365
            val daysLeft = totalDays - dayOfYear
            val monthName = String.format(Locale.getDefault(), "%tB", calendar).uppercase()

            // Theme Loading
            val themePrefix = "flutter." // Flutter prefixes keys
            val themeId = prefs.getString(themePrefix + "theme_id", "default") ?: "default"
            
            // Defaults
            var bgColor = Color.parseColor("#0F172A") // Slate 900
            var dotPassedColor = Color.parseColor("#66FFFFFF") // White 40%
            var dotTodayColor = Color.parseColor("#13C8EC") // Cyan
            var dotFutureColor = Color.parseColor("#1AFFFFFF") // White 10%
            var textColor = Color.WHITE
            var secondaryTextColor = Color.parseColor("#94A3B8") // Default Slate 400
            var showText = true
            var isSquare = false
            var gridColumns = 15 // Default Standard

            if (themeId.startsWith("custom_")) {
                 val bgVal = prefs.getLong(themePrefix + "theme_background", -1)
                 if (bgVal != -1L) bgColor = bgVal.toInt()

                 val colorVal = prefs.getLong(themePrefix + "theme_color", -1)
                 if (colorVal != -1L) dotTodayColor = colorVal.toInt()

                 val textVal = prefs.getLong(themePrefix + "theme_text_color", -1)
                 if (textVal != -1L) {
                     textColor = textVal.toInt()
                     // Derive secondary color (60% opacity) from primary if custom
                     secondaryTextColor = Color.argb(153, Color.red(textColor), Color.green(textColor), Color.blue(textColor))
                 }

                 showText = prefs.getBoolean(themePrefix + "theme_show_text", true)
                 
                 // Safe read for styleIndex (Flutter stores int as Long)
                 var styleIndex = 0
                 try {
                    styleIndex = prefs.getInt(themePrefix + "theme_style", 0)
                 } catch (e: ClassCastException) {
                    styleIndex = prefs.getLong(themePrefix + "theme_style", 0L).toInt()
                 }
                 
                 isSquare = (styleIndex == 1)
                 
                 // Grid Density (Safe Read)
                 try {
                     gridColumns = prefs.getInt(themePrefix + "theme_grid_columns", 15)
                 } catch (e: ClassCastException) {
                     gridColumns = prefs.getLong(themePrefix + "theme_grid_columns", 15L).toInt()
                 }
            }

            // Drawing
            canvas.drawColor(bgColor)

            val width = canvas.width.toFloat()
            val height = canvas.height.toFloat()

            val paint = Paint().apply { isAntiAlias = true }

            // Grid Logic
            val cols = gridColumns
            val rows = ceil(totalDays.toDouble() / cols).toInt()

            // Constraints (80% width)
            val maxWidth = width * 0.80f
            var cellWidth = maxWidth / cols
            var cellHeight = cellWidth * 1.15f

            // Vertical constraint check - Reserve 15% top/bottom for text safe area
            val maxHeight = height * 0.70f 
            if ((rows * cellHeight) > maxHeight) {
                cellHeight = maxHeight / rows
                cellWidth = cellHeight / 1.15f
            }

            val actualGridWidth = cols * cellWidth
            val actualGridHeight = rows * cellHeight

            // Center (No Bias)
            val startX = (width - actualGridWidth) / 2
            val startY = (height - actualGridHeight) / 2

            val dotRadius = cellWidth * 0.35f

            var currentDay = 1
            for (i in 0 until totalDays) {
                val col = i % cols
                val row = i / cols

                val cx = startX + (col * cellWidth) + (cellWidth / 2)
                val cy = startY + (row * cellHeight) + (cellHeight / 2)

                when {
                    currentDay < dayOfYear -> paint.color = dotPassedColor
                    currentDay == dayOfYear -> paint.color = dotTodayColor
                    else -> paint.color = dotFutureColor
                }

                if (isSquare) {
                    val size = dotRadius * 2
                    canvas.drawRoundRect(
                        cx - dotRadius, cy - dotRadius, 
                        cx + dotRadius, cy + dotRadius, 
                        size * 0.2f, size * 0.2f, paint
                    )
                } else {
                    canvas.drawCircle(cx, cy, dotRadius, paint)
                }
                currentDay++
            }

            // Text
            if (showText) {
                val textPaint = Paint().apply {
                    isAntiAlias = true
                    textAlign = Paint.Align.CENTER
                }

                // Month (Top) - 7%
                textPaint.color = secondaryTextColor // Use derived or default secondary
                textPaint.textSize = width * 0.05f
                textPaint.typeface = Typeface.create("sans-serif", Typeface.NORMAL)
                textPaint.letterSpacing = 0.2f // Android letter spacing is EM based
                
                canvas.drawText(monthName, width / 2f, height * 0.07f + textPaint.textSize, textPaint)

                // Bottom Stats - 7% from bottom
                val statsY = height - (height * 0.07f)
                
                val mainText = "$dayOfYear / $totalDays"
                val subText = "   $daysLeft left"

                textPaint.textSize = width * 0.05f
                textPaint.typeface = Typeface.create("sans-serif", Typeface.BOLD)
                val mainWidth = textPaint.measureText(mainText)
                
                textPaint.textSize = width * 0.035f
                textPaint.typeface = Typeface.create("sans-serif", Typeface.NORMAL)
                val subWidth = textPaint.measureText(subText)
                
                val totalWidth = mainWidth + subWidth
                var currentX = (width - totalWidth) / 2

                // Draw Main - Uses Dot Highlight Color (Theme Color) to match Flutter logic
                textPaint.color = dotTodayColor 
                textPaint.textSize = width * 0.05f
                textPaint.typeface = Typeface.create("sans-serif", Typeface.BOLD)
                textPaint.textAlign = Paint.Align.LEFT
                canvas.drawText(mainText, currentX, statsY, textPaint)
                
                currentX += mainWidth

                // Draw Sub - Uses Secondary with extra opacity (0.8 of secondary)
                // secondaryTextColor already has ~153 alpha (0.6). 
                // We need 0.8 relative to that? Or just 0.8 of opacity?
                // Flutter: theme.textSecondary.withOpacity(0.8) -> 0.48 absolute.
                // Let's just Apply 0.8 opacity to the secondaryTextColor base.
                val secR = Color.red(secondaryTextColor)
                val secG = Color.green(secondaryTextColor)
                val secB = Color.blue(secondaryTextColor)
                val secA = Color.alpha(secondaryTextColor)
                textPaint.color = Color.argb((secA * 0.8).toInt(), secR, secG, secB)

                textPaint.textSize = width * 0.035f
                textPaint.typeface = Typeface.create("sans-serif", Typeface.NORMAL)
                canvas.drawText(subText, currentX, statsY, textPaint)
            }
        }
    }
}
