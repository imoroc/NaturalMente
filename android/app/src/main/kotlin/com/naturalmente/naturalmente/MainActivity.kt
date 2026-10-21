package com.naturalmente.naturalmente

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val ejecutorAudio = Executors.newCachedThreadPool()
    @Volatile
    private var pistaMusica: AudioTrack? = null
    @Volatile
    private var musicaActiva: Boolean = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "naturalmente/audio"
        ).setMethodCallHandler { llamada, resultado ->
            when (llamada.method) {
                "reproducirPcm" -> {
                    val pcm = llamada.argument<ByteArray>("pcm")
                    val sampleRate = llamada.argument<Int>("sampleRate") ?: 22050
                    if (pcm != null && pcm.isNotEmpty()) {
                        reproducirPcm(pcm, sampleRate)
                    }
                    resultado.success(null)
                }
                "iniciarMusicaPcm" -> {
                    val pcm = llamada.argument<ByteArray>("pcm")
                    val sampleRate = llamada.argument<Int>("sampleRate") ?: 22050
                    if (pcm != null && pcm.isNotEmpty()) {
                        iniciarMusicaPcm(pcm, sampleRate)
                    }
                    resultado.success(null)
                }
                "detenerMusicaPcm" -> {
                    detenerMusicaPcm()
                    resultado.success(null)
                }
                else -> resultado.notImplemented()
            }
        }
    }

    private fun reproducirPcm(pcm: ByteArray, sampleRate: Int) {
        ejecutorAudio.execute {
            try {
                val pista = AudioTrack.Builder()
                    .setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_GAME)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    .setAudioFormat(
                        AudioFormat.Builder()
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .setSampleRate(sampleRate)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .build()
                    )
                    .setBufferSizeInBytes(pcm.size)
                    .setTransferMode(AudioTrack.MODE_STATIC)
                    .build()
                pista.write(pcm, 0, pcm.size)
                pista.play()
                val duracionMs = (pcm.size.toLong() * 500L) / sampleRate.toLong() + 90L
                Thread.sleep(duracionMs)
                pista.stop()
                pista.release()
            } catch (_: Throwable) {
            }
        }
    }

    @Synchronized
    private fun iniciarMusicaPcm(pcm: ByteArray, sampleRate: Int) {
        musicaActiva = true
        ejecutorAudio.execute {
            synchronized(this) {
                try {
                    pistaMusica?.let {
                        if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                            return@synchronized
                        }
                        it.release()
                    }
                    val totalFrames = pcm.size / 2
                    val pista = AudioTrack.Builder()
                        .setAudioAttributes(
                            AudioAttributes.Builder()
                                .setUsage(AudioAttributes.USAGE_GAME)
                                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                                .build()
                        )
                        .setAudioFormat(
                            AudioFormat.Builder()
                                .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                                .setSampleRate(sampleRate)
                                .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                                .build()
                        )
                        .setBufferSizeInBytes(pcm.size)
                        .setTransferMode(AudioTrack.MODE_STATIC)
                        .build()
                    pista.write(pcm, 0, pcm.size)
                    pista.setLoopPoints(0, totalFrames, -1)
                    if (musicaActiva) {
                        pista.play()
                        pistaMusica = pista
                    } else {
                        pista.release()
                    }
                } catch (_: Throwable) {
                }
            }
        }
    }

    @Synchronized
    private fun detenerMusicaPcm() {
        musicaActiva = false
        try {
            pistaMusica?.let {
                if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                    it.stop()
                }
                it.release()
            }
        } catch (_: Throwable) {
        } finally {
            pistaMusica = null
        }
    }

    override fun onPause() {
        try {
            pistaMusica?.let {
                if (it.playState == AudioTrack.PLAYSTATE_PLAYING) {
                    it.pause()
                }
            }
        } catch (_: Throwable) {
        }
        super.onPause()
    }

    override fun onResume() {
        super.onResume()
        if (musicaActiva) {
            try {
                pistaMusica?.play()
            } catch (_: Throwable) {
            }
        }
    }

    override fun onDestroy() {
        detenerMusicaPcm()
        super.onDestroy()
    }
}
